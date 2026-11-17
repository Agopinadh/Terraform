resource "aws_iam_role" "instance" {
  name = "${var.name}-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.name}-ec2"
  role = aws_iam_role.instance.name
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.name}-"
  image_id      = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.instance.name
  }

  vpc_security_group_ids = [aws_security_group.application.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -euxo pipefail
    dnf install -y nginx
    cat > /etc/nginx/conf.d/app.conf <<'NGINX'
    server {
      listen 80 default_server;
      listen 8080;
      server_name _;
      location / {
        default_type text/plain;
        return 200 "Terraform web tier is healthy\n";
      }
    }
    NGINX
    systemctl enable --now nginx
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-app"
    }
  }
}

resource "aws_lb" "application" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.load_balancer.id]

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_lb_target_group" "application" {
  name        = "${var.name}-app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name = "${var.name}-app"
  }
}

resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}

resource "aws_lb" "network" {
  name               = "${var.name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.app[*].id
  security_groups    = [aws_security_group.network_load_balancer.id]

  tags = {
    Name = "${var.name}-nlb"
  }
}

resource "aws_lb_target_group" "network" {
  name        = "${var.name}-tcp"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = "TCP"
  }

  tags = {
    Name = "${var.name}-tcp"
  }
}

resource "aws_lb_listener" "network" {
  load_balancer_arn = aws_lb.network.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network.arn
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.name}-app"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = aws_subnet.app[*].id
  target_group_arns   = [aws_lb_target_group.application.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  lifecycle {
    precondition {
      condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
      error_message = "desired_capacity must be between min_size and max_size."
    }
  }

  depends_on = [aws_iam_role_policy_attachment.ssm]

  tag {
    key                 = "Name"
    value               = "${var.name}-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "network" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.network.arn
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}

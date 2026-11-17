resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    precondition {
      condition     = (var.peer_vpc_id == "" && var.peer_vpc_cidr == "") || (var.peer_vpc_id != "" && var.peer_vpc_cidr != "")
      error_message = "Set both peer_vpc_id and peer_vpc_cidr to enable VPC peering, or leave both empty."
    }

    precondition {
      condition     = var.enable_transit_gateway || length(var.transit_gateway_routes) == 0
      error_message = "Set enable_transit_gateway to true when transit_gateway_routes are configured."
    }
  }

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs[count.index]
  cidr_block              = local.subnet_cidrs.public[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
    Tier = "public"
  }
}

resource "aws_subnet" "app" {
  count = 2

  vpc_id            = aws_vpc.main.id
  availability_zone = local.azs[count.index]
  cidr_block        = local.subnet_cidrs.app[count.index]

  tags = {
    Name = "${var.name}-app-${count.index + 1}"
    Tier = "application"
  }
}

resource "aws_subnet" "data" {
  count = 2

  vpc_id            = aws_vpc.main.id
  availability_zone = local.azs[count.index]
  cidr_block        = local.subnet_cidrs.data[count.index]

  tags = {
    Name = "${var.name}-data-${count.index + 1}"
    Tier = "data"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-app"
  }
}

resource "aws_route_table_association" "app" {
  count = 2

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-data"
  }
}

resource "aws_route_table_association" "data" {
  count = 2

  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.name}-nat"
  }
}

resource "aws_route" "app_nat" {
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_security_group" "load_balancer" {
  name        = "${var.name}-alb"
  description = "Public HTTP access to the application load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_security_group" "network_load_balancer" {
  name        = "${var.name}-nlb"
  description = "Private TCP access to the network load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "VPC-internal TCP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.name}-nlb"
  }
}

resource "aws_security_group" "application" {
  name        = "${var.name}-app"
  description = "Application instances accept traffic only from load balancers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description     = "TCP from internal NLB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.network_load_balancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-app"
  }
}

resource "aws_security_group" "endpoints" {
  name        = "${var.name}-endpoints"
  description = "HTTPS from application instances to VPC interface endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS from application instances"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-endpoints"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.app.id]

  tags = {
    Name = "${var.name}-s3"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(["ssm", "ssmmessages", "ec2messages"])

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.app[*].id
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

resource "aws_vpc_peering_connection" "peer" {
  count = var.peer_vpc_id != "" ? 1 : 0

  vpc_id      = aws_vpc.main.id
  peer_vpc_id = var.peer_vpc_id
  peer_region = var.aws_region
  auto_accept = true

  lifecycle {
    precondition {
      condition     = var.peer_vpc_cidr != ""
      error_message = "peer_vpc_cidr must be set when peer_vpc_id is configured."
    }
  }

  tags = {
    Name = "${var.name}-peer"
  }
}

resource "aws_route" "peer" {
  count = var.peer_vpc_id != "" ? 3 : 0

  route_table_id            = [aws_route_table.public.id, aws_route_table.app.id, aws_route_table.data.id][count.index]
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[0].id
}

resource "aws_ec2_transit_gateway" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  description                     = "${var.name} transit gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "${var.name}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  subnet_ids         = aws_subnet.app[*].id
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id
  vpc_id             = aws_vpc.main.id

  tags = {
    Name = "${var.name}-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_route" "static" {
  for_each = var.enable_transit_gateway ? var.transit_gateway_routes : {}

  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main[0].association_default_route_table_id
}

resource "aws_route" "transit_gateway" {
  for_each = var.enable_transit_gateway ? var.transit_gateway_routes : {}

  route_table_id         = aws_route_table.app.id
  destination_cidr_block = each.key
  transit_gateway_id     = aws_ec2_transit_gateway.main[0].id
}

# Creation of Key Pair
resource "aws_key_pair" "example" {
  key_name   = "task"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Example EC2 instance (replace with yours if already existing)
resource "aws_instance" "sql_runner" {
  ami                         = "ami-06f98347e4f9c7328"
  instance_type               = "t2.micro"
  key_name                    = "task"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.name.id
  vpc_security_group_ids      = [aws_security_group.name.id]
  tags = {
    Name = "SQL-Runner"
  }
}
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"

}

# Creation of Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id

  tags = {
    Name = "Dev-igw"
  }
}

# Creation of public route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Dev-rt"
  }
}

# Association of route table with public subnet
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.name.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_subnet" "name" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "name2" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_db_subnet_group" "name" {
  name       = "my-subnet-group"
  subnet_ids = [aws_subnet.name.id, aws_subnet.name2.id]
}

resource "aws_security_group" "name" {
  name        = "my-security-group"
  description = "Allow SSH and MySQL traffic"
  vpc_id      = aws_vpc.name.id

  # SSH access from your computer
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["102.132.234.222/32"]
  }

  # MySQL access within VPC
  ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# RDS MySQL Instance
resource "aws_db_instance" "name" {
  identifier             = "my-rds-instance"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.name.name
  vpc_security_group_ids = [aws_security_group.name.id]
  skip_final_snapshot    = true
  username               = "admin"
  password               = "Cloud123"
  #manage_master_user_password = true rds with secret manager secrets will be in secret manager and password will be auto rotated
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

}

# Deploy SQL remotely using null_resource + remote-exec
resource "null_resource" "remote_sql_exec" {
  depends_on = [aws_db_instance.name, aws_instance.sql_runner]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519") #Replace with your PEM file path
    host        = aws_instance.sql_runner.public_ip
  }

  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install mariadb105 -y ",
      "mysql --version",
      #"mysql -h ${aws_db_instance.name.address} -u ${jsondecode(aws_secretsmanage_secret_version.rds_secret_value.secret_string)["username"]} -p${jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["password"]} < /tmp/init.sql" 
      "mysql -h ${aws_db_instance.name.address} -u admin -pCloud123 < /tmp/init.sql"
    ]

  }
  triggers = {
    always_run = timestamp() # Trigger everytime apply
  }

}

# terraform taint null_resource.remote_sql_exec we can use taint also for alternate to trigger 
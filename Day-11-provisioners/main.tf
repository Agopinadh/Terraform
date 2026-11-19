
# Key Pair
resource "aws_key_pair" "example" {
  key_name   = "task" # Replace with your desired key name
  public_key = file("~/.ssh/id_ed25519.pub")
}

# VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# SUBNET
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# ROUTE TABLE
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# ASSOCIATION ROUTE TABLE
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

# SECURITY GROUP
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "Web-sg"
  }
}

# EC2 INSTANCE
resource "aws_instance" "server" {
  ami                         = "ami-0261755bbcb8c4a84"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.example.key_name
  subnet_id                   = aws_subnet.sub1.id
  vpc_security_group_ids      = [aws_security_group.webSg.id]
  associate_public_ip_address = true

  tags = {
    Name = "UbuntuServer"
  }

  # connection {
  #   type = "ssh"
  #   user = "ubuntu" # Replace with the appropriate username for your EC2 instance
  #   # private_key = file("C:/Users/veerababu/.ssh/id_rsa")
  #   private_key = file("~/.ssh/id_ed25519") #private key path
  #   host        = self.public_ip            #or we can use aws_instance.server.public_ip
  #   timeout     = "2m"
  # }

  # # File provisioner to copy a file from local to the remote EC2 instance
  # provisioner "file" {
  #   source      = "file10"              # Replace with the path to your local file
  #   destination = "/home/ubuntu/file10" # Replace with the path on the remote instance
  # }
  # # remote execution process 
  # provisioner "remote-exec" {
  #   inline = [
  #     "touch /home/ubuntu/file200",
  #     "echo 'hello from aws from Lenovo' >> /home/ubuntu/file200", ##mysql -h -u user -p
  #   ]
  # }
  # provisioner "local-exec" {
  #   command = "touch file 500"

  # }
}
resource "null_resource" "run_script" {
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.server.public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
    }
  # provisioner "file"
  #   {
  #     source = "file10"
  #     destination = "/home/ubuntu.dev.sh"
  #   }  
    inline = ["echo 'Hello from aws Lenovo' >> /home/ubuntu/file200"]
    # i want to run test.sh script
    #"bash /home/ubuntu.test.sh" # Assuming test.sh is already on the instance
  }


  triggers = {
    always_run = "${timestamp()}" # Forces rerun everytime
    script_hash = filemd5("dev.sh") # Rerun only if script changes
}
}


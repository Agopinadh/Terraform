resource "aws_instance" "name" {
  ami           = "ami-06f98347e4f9c7328"
  instance_type = "t3.micro"
  user_data     = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello, World! from Lenovo" > /var/www/html/index.html
              EOF

              # user data is a script that will be executed on the instance when it is launched. In this case we are installing and starting the Apache web server and creating a simple index.html file.
              #modification is not possible? to the user data script to customize? no, the instance as per your requirements. For example, you can install additional software, configure services, or run any othercommands that you want to execute on the instance at launch time.
              # we can modify existing user data script by using provisioners without delete and create server.
             
  tags = {
    Name = "My-Instance"
  }
}
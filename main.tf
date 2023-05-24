provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

resource "aws_instance" "django_instance" {
  ami           = "ami-0261755bbcb8c4a84"  # Replace with the desired AMI ID
  instance_type = "t2.micro"  # Replace with the desired instance type

  # Security group allowing inbound access on all ports
  vpc_security_group_ids = [aws_security_group.open_ports.id]

  # User data script to install necessary packages and run Django app
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y python3-pip
              pip3 install django
              pip3 install uvicorn

              # Create a Django starter project
              django-admin startproject myproject

              # Change to project directory
              cd myproject

              # Run the Django app on port 80 using uvicorn
              uvicorn myproject.asgi:application --host 0.0.0.0 --port 80
              EOF
}


resource "aws_security_group" "open_ports" {
  name        = "open-ports"
  description = "Allow inbound access on all ports"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "public_dns" {
  value = aws_instance.django_instance.public_dns
}

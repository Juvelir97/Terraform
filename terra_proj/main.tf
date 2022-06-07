provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c4f7023847b90238"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "NVIRG"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web.id
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y
  sudo systemctl start apache2
  sudo chown -R ubuntu:ubuntu /var/www/html/index.html
  echo 'hi it's my proj' > /var/www/html/index.html
  EOF

  tags = {
    Name = "my web serv"
  }

  
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_for_web.id

  tags = {
    Name = "web"
  }
}

resource "aws_network_interface" "web" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.web.id]
  depends_on = [aws_internet_gateway.gw]
  
}

resource "aws_eip" "myweb" {
  vpc                       = true
  network_interface         = aws_network_interface.web.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
    
  
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.vpc_for_web.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "web"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.web.id
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.vpc_for_web.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet-1"
  }
}

resource "aws_vpc" "vpc_for_web" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "web"
  }
}


resource "aws_security_group" "web" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_for_web.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

    ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
  

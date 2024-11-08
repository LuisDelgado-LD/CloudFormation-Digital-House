terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
}

resource "aws_key_pair" "mi-llave" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINPlA6feEkmFmx+FDOsIjSkzi9Gm00eIywdg+VqwWgt yikoru@fenix-rabbit"
}

resource "aws_vpc" "Mi-vpc" {
  cidr_block = "10.16.0.0/20"

  tags = {
    Name = "vpc clase DH"
  }
}

resource "aws_internet_gateway" "inet-gw" {
  vpc_id            = aws_vpc.Mi-vpc.id
  tags = {
   Name ="Mi IG"
 }
}

resource "aws_route_table" "TablaGW" {
  vpc_id            = aws_vpc.Mi-vpc.id

  route {
   gateway_id = aws_internet_gateway.inet-gw.id
   cidr_block        = "0.0.0.0/0"
 }
 tags ={
  Name= "Ruta a internet"
 }
}

resource "aws_lb" "ALB" {
  name = "ALB-WEB"
  internal = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.WEB.id]
  subnets = [aws_subnet.pub-subnet-1, aws_subnet.pub-subnet-2]
  tags = {
    Name = "ALB WEB"
  }
}

resource "aws_lb_target_group" "Grupo" {
  name = "tg-alb-web"
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.Mi-vpc.id
  health_check {
    enabled = true
    interval = 5
    matcher = 200
    protocol = "HTTP"
    timeout = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "Listener" {
  load_balancer_arn = aws_lb.ALB.id
  protocol = "HTTP"
  default_action {
    type = "forward"
    forward {
    target_group{
      arn = aws_lb_target_group.Grupo.id
      }
    }
  }

  tags = {
    Name = "Listener ALB WEB"
  }
}


resource "aws_route_table_association" "Asociacion1" {
  subnet_id = aws_subnet.pub-subnet-1.id
  route_table_id = aws_route_table.TablaGW.id
}
resource "aws_route_table_association" "Asociacion2" {
  subnet_id = aws_subnet.pub-subnet-2.id
  route_table_id = aws_route_table.TablaGW.id
}

resource "aws_security_group" "SSH" {
 name = "Trafico SSH"
 vpc_id = aws_vpc.Mi-vpc.id
 tags = {
  Name = "SSH"
 }
}

resource "aws_security_group" "WEB" {
 name = "Trafico web"
 vpc_id = aws_vpc.Mi-vpc.id
 tags = {
  Name = "HTTP/S"
 }
}

resource "aws_security_group" "SalidaInet" {
 name = "TraficoSSH"
 vpc_id = aws_vpc.Mi-vpc.id
 tags = {
  Name = "SSH"
 }
}

resource "aws_vpc_security_group_ingress_rule" "HTTP" {
 security_group_id = aws_security_group.WEB.id
 cidr_ipv4 = "0.0.0.0/0"
 from_port = 80
 ip_protocol = "tcp"
 to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "HTTPS" {
 security_group_id = aws_security_group.WEB.id
 cidr_ipv4 = "0.0.0.0/0"
 from_port = 443
 ip_protocol = "tcp"
 to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "SSHINPUB" {
 security_group_id = aws_security_group.SSH.id
 cidr_ipv4 = "0.0.0.0/0"
 from_port = 22
 ip_protocol = "tcp"
 to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "INETOUT" {
 security_group_id = aws_security_group.SalidaInet.id
 cidr_ipv4 = "0.0.0.0/0"
 ip_protocol = "-1"
}

resource "aws_subnet" "pub-subnet-1" {
  vpc_id            = aws_vpc.Mi-vpc.id
  cidr_block        = "10.16.1.0/24"
  availability_zone = "us-east-1a"
  #map_public_ip_on_launch = true
  tags = {
    Name = "pub-subnet-1"
  }
}

resource "aws_subnet" "pub-subnet-2" {
  vpc_id            = aws_vpc.Mi-vpc.id
  cidr_block        = "10.16.2.0/24"
  availability_zone = "us-east-1b"
  #map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-2"
  }
}

resource "aws_subnet" "priv-subnet-1" {
  vpc_id            = aws_vpc.Mi-vpc.id
  cidr_block        = "10.16.3.0/24"
  availability_zone = "us-east-1a"
  #map_public_ip_on_launch = true

  tags = {
    Name = "priv-subnet-1"
  }
}

resource "aws_subnet" "priv-subnet-2" {
  vpc_id            = aws_vpc.Mi-vpc.id
  cidr_block        = "10.16.4.0/24"
  availability_zone = "us-east-1b"
  #map_public_ip_on_launch = true

  tags = {
    Name = "priv-subnet-2"
  }
}


resource "aws_instance" "Instancia1" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name      = "deployer-key"
  associate_public_ip_address = true
  subnet_id = aws_subnet.pub-subnet-1.id
  vpc_security_group_ids = [aws_security_group.SSH.id,aws_security_group.SalidaInet.id,aws_security_group.WEB.id]
  tags = {
    Name = "Instancia 1"
  }
}

resource "aws_instance" "Instancia2" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name      = "deployer-key"
  associate_public_ip_address = true
  subnet_id = aws_subnet.pub-subnet-2.id
  vpc_security_group_ids = [aws_security_group.SSH.id,aws_security_group.SalidaInet.id]
  tags = {
    Name = "Instancia 2"
  }
}

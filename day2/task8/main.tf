terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
}
resource "aws_vpc" "my-first" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "production"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-first.id
}

resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.my-first.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-igw"
  }
}


resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.my-first.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "prod-private"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.igw.id
}

resource "aws_security_group" "allow_protocols" {
  name        = "allow_protocols"
  description = "Allow http,https, and ssh"
  vpc_id      = aws_vpc.my-first.id

  tags = {
    Name = "allow_protocols"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_protocols.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.allow_protocols.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_protocols.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_protocols.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "vockey3"
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_protocols.id]

  tags = {
    Name = "web"
  }

  provisioner "local-exec" {
  command = <<EOT
    echo "Waiting 150 seconds for EC2 to initialize..."
    sleep 150
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --inventory '${aws_instance.web.public_ip},' playbook.yaml --private-key /var/jenkins_home/vockey3.pem --user ubuntu
EOT
}

  }

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}
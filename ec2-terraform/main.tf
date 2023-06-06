data "aws_key_pair" "tentech" {
  key_name = "tentech"
}

# create vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/26"
  tags = {
    Name = "docker-vpc"
  }
}

# data call for azs:
data "aws_availability_zones" "azs" {
  state = "available"
}

# create  public subnet in 1a:
resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-1a"
  }
}


# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

# create EIP
resource "aws_eip" "eip" {
  vpc = true
}


# create public route table
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

# assiate public rtb with public-1a
resource "aws_route_table_association" "public-rtb-public-1a" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id      = aws_subnet.public-1a.id
}


# security group
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "Allow SSH from anywhere inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http from anywhere for ec2 web server"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http from anywhere for container web server "
    from_port   = 5000
    to_port     = 5002
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
    Name = "public-sg"
  }
}

# data call for ami:
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# # output
# output "name2" {
#   value = data.aws_ami.amazon-linux-2.id
# }

# launch an EC2-1 instance:
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.public-1a.id
  key_name               = data.aws_key_pair.tentech.key_name
  vpc_security_group_ids = [aws_security_group.public-sg.id]

  user_data = <<EOF
  #!/bin/bash
  set -ex
  yum update -y
  yum install httpd -y
  echo "<h1>This is EC2-instance: $(hostname -f)</h1>" > /var/www/html/index.html 
  systemctl start httpd
  systemctl enable httpd
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo curl -L https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  EOF

  tags = {
    Name = "public-ec2"
  }
}



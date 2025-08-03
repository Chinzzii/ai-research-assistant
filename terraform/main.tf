provider "aws" {
  region = "us-east-1"
}

variable "openai_api_key" {
  type      = string
  sensitive = true
}

resource "aws_key_pair" "deployer" {
  key_name   = "research-key"
  public_key = file("${pathexpand("~/.ssh/id_rsa.pub")}")
}

resource "aws_vpc" "custom" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "custom-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "custom-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_subnet" "custom_subnet" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "custom-subnet"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.custom_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "research_sg" {
  name        = "research_sg"
  description = "Allow SSH and Streamlit access"
  vpc_id      = aws_vpc.custom.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "research_app" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t3a.medium"
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.custom_subnet.id
  vpc_security_group_ids = [aws_security_group.research_sg.id]

  user_data = templatefile("${path.module}/cloud-init.sh", {
    openai_api_key = var.openai_api_key
  })

  tags = {
    Name = "ResearchAssistant"
  }
}
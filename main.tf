provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "research-assistant-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "research_sg" {
  name        = "research_sg"
  description = "Allow SSH, Streamlit, and Flask"

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

  ingress {
    from_port   = 5000
    to_port     = 5000
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

resource "aws_instance" "research_instance" {
  ami           = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS
  instance_type = "t3a.medium"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.research_sg.name]

  tags = {
    Name = "research-assistant"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    inline = [
      "sudo apt update && sudo apt install -y python3-pip",
      "pip3 install streamlit flask faiss-cpu torch sentence-transformers ctransformers",
      "mkdir -p ~/app && echo 'put project files here'"
    ]
  }
}

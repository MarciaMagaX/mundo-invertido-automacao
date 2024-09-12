provider "aws" {
  region = "us-east-1"
}

# Security Group para permitir SSH
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh"

  ingress {
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
}

# Security Group para permitir HTTP na porta 80
resource "aws_security_group" "allow_http" {
  name_prefix = "allow_http"

  ingress {
    from_port   = 80
    to_port     = 80
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

# Recurso para criar a instância AWS
resource "aws_instance" "first-site" {
  ami           = "ami-0a0e5d9c7acc336f1"  # AMI Ubuntu 20.04 para us-east-1
  instance_type = "t2.micro"
  key_name      = "terraform2"

  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id
  ]

  associate_public_ip_address = true        # Habilitar IP público

  user_data = <<-EOF
#!/bin/bash

# Atualiza os pacotes e instala o Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Adiciona o usuário 'ubuntu' ao grupo 'docker'
sudo usermod -aG docker ubuntu

# Executa o container com a imagem fornecida
sudo docker pull marciamagax/meusite-bootcamp-devops:1.0
sudo docker run -d -p 80:80 marciamagax/meusite-bootcamp-devops:1.0
EOF

  tags = {
    Name = "first-site"
  }
}

# Saída do IP público da instância
output "instance_public_ip" {
  value = aws_instance.first-site.public_ip
}

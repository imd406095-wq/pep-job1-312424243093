#Key Pair (login)

resource "aws_key_pair" "my_key" {
    key_name = "demo-key"
    public_key = tls_private_key.rsa.public_key_openssh
  
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf_file" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}


#Security Group
resource "aws_security_group" "my_security" {
  name = "automate-sg"
  description = "This will add a TF generate security Group"
  vpc_id = aws_vpc.demovpc.id #interpolation

  #Inbound Rules
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }

  #Outbound Rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All access open Outbound"
  }

  tags = {
    name = "automate-sg"
  }
}

# ec2 instance

resource "aws_instance" "my_instance" {
  key_name = aws_key_pair.my_key.key_name 
  vpc_security_group_ids = [aws_security_group.my_security.id]
  instance_type = var.ec2_instance_type #Interpolation
  ami = var.ec2_ami_id #AWS Linux

  subnet_id = aws_subnet.pub-sub.id
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker $USER
              newgrp docker
              EOF
  

  root_block_device {
    volume_size = var.ec2_root_storage_size 
    volume_type = "gp3"
  }

  tags = {
    name = "SJIT-pep-cloud"
  }

  depends_on = [
    aws_route_table_association.public_association
  ]
}

#Key Pair (login)

resource "aws_key_pair" "my_key" {
    key_name = "terraform-key-ec2"
    public_key = file("terraform-key-ec2.pub")
  
}

# VPC & security Group

resource "aws_default_vpc" "default" {
  
}

#Security Group
resource "aws_security_group" "my_security" {
  name = "automate-sg"
  description = "This will add a TF generate security Group"
  vpc_id = aws_default_vpc.default.id #interpolation

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
  security_groups = [aws_security_group.my_security.name]
  instance_type = var.ec2_instance_type #Interpolation
  ami = var.ec2_ami_id #AWS Linux

  root_block_device {
    volume_size = var.ec2_root_storage_size 
    volume_type = "gp3"
  }

  tags = {
    name = "SJIT-pep-cloud"
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

provider "aws" {
  # Configuration options
}
  

resource "aws_instance" "ansible" {
  tags = {
    Name = "ansible"
  }
  
  ami = "ami-0f007bf1d5c770c6e"
  instance_type = "t2.micro"
  key_name = "Putty"
  security_groups = [ "default" ]
  user_data = <<-EOF
  #!/bin/bash
  sudo su -
  useradd ansible
  echo "password" | passwd ansible
  sudo yum install ansible -y
  EOF
}

resource "aws_instance" "sparrow" {
  tags = {
    Name="sparrow"
    }
    ami = "ami-0f007bf1d5c770c6e"
    instance_type = "t2.micro"
    key_name = "Putty"
    security_groups = [ "default" ]
}

resource "null_resource" "update_inventory" {
  provisioner "local-exec" {
    command = "powershell -File update_inventory.ps1"
  }
  depends_on = [ aws_instance.sparrow ]
}

output "sparrow_ip" {
  value = aws_instance.sparrow.public_ip
}
output "ansible_ip" {
  value = aws_instance.ansible.public_ip
}
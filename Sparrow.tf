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

  # Install Ansible
  sudo yum update -y
  sudo yum install ansible -y

  # Configure SSH for passwordless login
  sudo sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
  sudo sed -i '/^#PubkeyAuthentication/s/^#//' /etc/ssh/sshd_config
  sudo systemctl restart sshd
  sudo useradd ansible
  echo "password" | sudo passwd --stdin ansible
  sudo usermod -aG wheel ansible


  # Add ansible_user to sudoers without password
  echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/ansible_user

 # Add public IP of another EC2 server to Ansible hosts file
  echo "[sparrow]" | sudo tee -a /etc/ansible/hosts
  echo "${aws_instance.sparrow.public_ip}" | sudo tee -a /etc/ansible/hosts

  sudo 
  EOF

#   provisioner "remote-exec" {
#     inline = [ 
#       "sudo yum install ansible -y"
#      ]
#      connection {
#        type = "ssh"
#        host = self.public_ip
#        user = ec2-user
#      }
#   }
# }
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



# output "sparrow_ip" {
#   value = aws_instance.sparrow.public_ip
# }
output "ansible_ip" {
  value = aws_instance.ansible.public_ip
}
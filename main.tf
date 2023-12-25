provider "aws" {
  region     = "us-east-1"  # Change this to your desired AWS region

}

resource "aws_instance" "example" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kp.key_name  # Associate the key pair with the instance
  tags = {
    Name = "terraform-example"
  }

  provisioner "local-exec" {
    command = "sleep 60"  # Wait for the instance to be ready
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install default-jre -y",
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.pk.private_key_pem
      host        = self.public_ip
    }
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "aws-Keys2"       # Create a "aws-Keys" key pair in AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a "aws-Keys2.pem" file on your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./aws-Keys2.pem"
  }
}

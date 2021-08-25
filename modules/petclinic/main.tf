resource "aws_security_group" "http_sg" {
  name        = "http_sg"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh

  #  provisioner "local-exec" {
  #    command = "echo '${tls_private_key.key.private_key_pem}' > ./${var.key_name}.pem"
  #  }
}

resource "local_file" "private_key" {
  content = "${tls_private_key.key.private_key_pem}"
  filename = "./${var.key_name}.pem"
  file_permission = "400"
}

data "template_file" "test" {
  template = <<-EOF
   #!/bin/bash
   echo "MYSQL_PASS=${var.key_name}" >> /etc/environment
   echo "MYSQL_URL=/jdk1.8.0_172" >> /etc/environment
   echo "MYSQL_USER=/jdk1.8.0_172" >> /etc/environment
   echo "spring_profiles_active=/jdk1.8.0_172" >> /etc/environment
  EOF
}

resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = var.instances_count
  key_name      = aws_key_pair.generated_key.key_name
  user_data = base64encode(data.template_file.test.rendered)
  subnet_id = var.aws_pub_subnet.0.ip
  vpc_security_group_ids = [aws_security_group.http_sg.id]
  tags = {
    Name  = "Instance-${count.index + 1}"
  }
}
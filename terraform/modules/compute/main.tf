resource "aws_key_pair" "ssh" {
  key_name   = "deploying-web-app-using-ansible-key"
  public_key = file(var.ssh_public_key_path)

  lifecycle {
    prevent_destroy = false
  }
}

# Ubuntu 22.04 LTS AMI (Canonical)
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "sandbox" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.ssh.key_name

  tags = {
    Name = "CICD Automation AWS Sandbox"
  }
}

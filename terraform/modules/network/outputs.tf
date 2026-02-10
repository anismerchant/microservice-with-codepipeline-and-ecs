output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "ssh_sg_id" {
  value = aws_security_group.ssh.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public.id,
    aws_subnet.public_2.id
  ]
}
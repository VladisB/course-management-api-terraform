output "instance" {
  value = aws_instance.jumpbox-instance
}

output "jumpbox-sg" {
  value = aws_security_group.jump-box-sg
}
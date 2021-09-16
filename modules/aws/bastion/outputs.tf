
output "public_ip" {
  description = "the public ip address for ssh"
  value       = aws_instance.bastion.public_ip
}
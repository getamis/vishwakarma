output "vpc_id" {
  description = "vpc id created by this module"
  value       = aws_vpc.new_vpc.id
}

output "public_subnet_ids" {
  description = "resource can be accessed publicly when use it"
  value       = aws_subnet.public_subnet.*.id
}

output "private_subnet_ids" {
  description = "resource can not be accessed publicly when use it"
  value       = aws_subnet.private_subnet.*.id
}

output "bastion_public_ip" {
  description = "the public ip address for ssh"
  value       = aws_instance.bastion.public_ip
}

output "zone_id" {
  description = "private zone id for Kubernetes"
  value       = var.private_zone ? join("", aws_route53_zone.zone.*.zone_id) : ""
}

output "vpc_cidr" {
  description = "The CIDR block for AWS VPC."
  value       = var.cidr_block
}
output "vpc_id" {
  value       = "${aws_vpc.new_vpc.id}"
  description = "vpc id created by this module"
}

output "public_subnet_ids" {
  value       = ["${aws_subnet.public_subnet.*.id}"]
  description = "resource can be accessed publicly when use it"
}

output "private_subnet_ids" {
  value       = ["${aws_subnet.private_subnet.*.id}"]
  description = "resource can not be accessed publicly when use it"
}

output "bastion_public_ip" {
  value       = "${aws_instance.bastion.public_ip}"
  description = "the public ip address for ssh"
}

output "zone_id" {
  value = "${var.private_zone ? join("", aws_route53_zone.zone.*.zone_id) : ""}"
  description = "private zone id for k8s"
}

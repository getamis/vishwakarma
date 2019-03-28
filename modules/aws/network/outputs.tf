output "vpc_id" {
  value = "${aws_vpc.new_vpc.id}"
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "zone_id" {
  value = "${var.private_zone ? join("", aws_route53_zone.zone.*.zone_id) : ""}"
}

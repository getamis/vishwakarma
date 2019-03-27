data "aws_route53_zone" "etcd" {
  zone_id      = "${var.zone_id}"
  private_zone = true
}

locals {
  discovery_service = "${substr(data.aws_route53_zone.etcd.name, 0, length(data.aws_route53_zone.etcd.name) - 1)}"
}

data "template_file" "etcd_names" {
  count    = "${var.etcd_config["instance_count"]}"
  template = "ip-${replace(aws_instance.etcd.*.private_ip[count.index], ".", "-")}.${local.discovery_service}"
}

data "template_file" "etcd_endpoints" {
  count    = "${var.etcd_config["instance_count"]}"
  template = "${format("https://%s:%s", data.template_file.etcd_names.*.rendered[count.index], local.client_port)}"
}

resource "aws_route53_record" "etcd_discovery" {
  zone_id = "${data.aws_route53_zone.etcd.zone_id}"
  name    = "${local.discovery_service}"
  type    = "SRV"
  ttl     = "300"
  records = ["${formatlist("0 0 %s %s", local.peer_port, data.template_file.etcd_names.*.rendered)}"]
}

resource "aws_route53_record" "etcd_discovery_server_ssl" {
  zone_id = "${data.aws_route53_zone.etcd.zone_id}"
  name    = "_etcd-server-ssl._tcp.${local.discovery_service}"
  type    = "SRV"
  ttl     = "300"
  records = ["${formatlist("0 0 %s %s", local.peer_port, data.template_file.etcd_names.*.rendered)}"]
}

resource "aws_route53_record" "etcd_discovery_client_ssl" {
  zone_id = "${data.aws_route53_zone.etcd.zone_id}"
  name    = "_etcd-client-ssl._tcp.${local.discovery_service}"
  type    = "SRV"
  ttl     = "300"
  records = ["${formatlist("0 0 %s %s", local.client_port, data.template_file.etcd_names.*.rendered)}"]
}

resource "aws_route53_record" "etcd" {
  count   = "${var.etcd_config["instance_count"]}"
  zone_id = "${data.aws_route53_zone.etcd.zone_id}"
  name    = "${data.template_file.etcd_names.*.rendered[count.index]}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.etcd.*.private_ip[count.index]}"]
}

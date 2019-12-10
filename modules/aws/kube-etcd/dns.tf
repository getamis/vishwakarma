data "aws_route53_zone" "etcd" {
  zone_id      = var.zone_id
  private_zone = true
}

locals {
  discovery_service = substr(data.aws_route53_zone.etcd.name, 0, length(data.aws_route53_zone.etcd.name) - 1)
}

resource "aws_route53_record" "etcd_discovery" {
  zone_id = data.aws_route53_zone.etcd.zone_id
  name    = local.discovery_service
  type    = "SRV"
  ttl     = "300"
  records = [
    for instance_ip in aws_instance.etcd.*.private_ip :
    "0 0 ${local.peer_port} ip-${replace(instance_ip, ".", "-")}.${local.discovery_service}"
  ]
}

resource "aws_route53_record" "etcd_discovery_server_ssl" {
  zone_id = data.aws_route53_zone.etcd.zone_id
  name    = "_etcd-server-ssl._tcp.${local.discovery_service}"
  type    = "SRV"
  ttl     = "300"
  records = [
    for instance_ip in aws_instance.etcd.*.private_ip :
    "0 0 ${local.peer_port} ip-${replace(instance_ip, ".", "-")}.${local.discovery_service}"
  ]
}

resource "aws_route53_record" "etcd_discovery_client_ssl" {
  zone_id = data.aws_route53_zone.etcd.zone_id
  name    = "_etcd-client-ssl._tcp.${local.discovery_service}"
  type    = "SRV"
  ttl     = "300"

  records = [
    for instance_ip in aws_instance.etcd.*.private_ip :
    "0 0 ${local.client_port} ip-${replace(instance_ip, ".", "-")}.${local.discovery_service}"
  ]
}

resource "aws_route53_record" "etcd" {
  count   = var.etcd_config["instance_count"]
  zone_id = data.aws_route53_zone.etcd.zone_id
  name    = "ip-${replace(aws_instance.etcd.*.private_ip[count.index], ".", "-")}.${local.discovery_service}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.etcd.*.private_ip[count.index]]
}
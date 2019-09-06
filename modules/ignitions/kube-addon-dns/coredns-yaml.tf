data "template_file" "coredns_yaml" {
  template = file("${path.module}/resources/kubernetes/manifests/coredns.yaml")

  vars = {
    image               = var.image
    reverse_cidrs       = var.reverse_cidrs
    cluster_dns_ip      = var.cluster_dns_ip
    cluster_domain      = var.cluster_domain
    federations         = var.federations
    subdomains          = var.subdomains
    upstream_nameserver = var.upstream_nameserver
  }
}

data "ignition_file" "coredns_yaml" {
  filesystem = local.filesystem
  mode       = local.mode

  path = "${pathexpand(var.addon_path)}/coredns.yaml"

  content {
    content = data.template_file.coredns_yaml.rendered
  }
}

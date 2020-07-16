locals {
  kube_proxy_cm_v1alpha1 = {
    data = {
      "config.conf" = merge(local.kube_proxy_config, {
        apiVersion = "kubeproxy.config.k8s.io/v1alpha1"
        kind       = "KubeProxyConfiguration"
      })
    }
  }
}

data "ignition_file" "kube_proxy" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/kube-proxy.yaml"

  content {
    content = templatefile("${path.module}/templates/addons/kube-proxy.yaml.tpl", {
      image = "${local.containers["kube_proxy"].repo}:${local.containers["kube_proxy"].tag}"
    })
  }
}

data "ignition_file" "kube_proxy_cm" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/kube-proxy-cm.yaml"

  content {
    content = templatefile("${path.module}/templates/addons/kube-proxy-cm.yaml.tpl", {
      endpoint = var.internal_endpoint
      content  = local.kube_proxy_cm_v1alpha1
    })
  }
}

// TODO: add support for stub-domains 
data "ignition_file" "coredns" {
  count = var.control_plane ? 1 : 0

  filesystem = "root"
  mode       = 420
  path       = "${local.addons_path}/coredns.yaml"

  content {
    content = templatefile("${path.module}/templates/addons/coredns.yaml.tpl", {
      image                    = "${local.containers["coredns"].repo}:${local.containers["coredns"].tag}"
      replicas                 = local.coredns_config["replicas"]
      reverse_cirds            = local.coredns_config["reverse_cirds"]
      cluster_dns_ip           = local.coredns_config["cluster_dns_ip"]
      cluster_domain           = local.coredns_config["cluster_domain"]
      upstream_nameserver      = local.coredns_config["upstream_nameserver"]
      located_on_the_same_host = local.coredns_config["located_on_the_same_host"]
    })
  }
}

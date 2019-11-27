data "template_file" "coredns_yaml" {
  template = file("${path.module}/resources/kubernetes/manifests/coredns.yaml")

  vars = {
    image                    = var.image
    replicas                 = var.replicas
    reverse_cidrs            = var.reverse_cidrs
    cluster_dns_ip           = var.cluster_dns_ip
    cluster_domain           = var.cluster_domain
    federations              = var.federations
    subdomains               = var.subdomains
    upstream_nameserver      = var.upstream_nameserver
    located_on_the_same_host = var.located_on_the_same_host

    required_pod_anti_affinity = <<EOF
          requiredDuringSchedulingIgnoredDuringExecution:
          - topologyKey: kubernetes.io/hostname
            labelSelector:
              matchExpressions:
              - key: k8s-app
                operator: In
                values:
                - kube-dns 
EOF

    preferred_pod_anti_affinity = <<EOF
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            podAffinityTerm:
              topologyKey: kubernetes.io/hostname
              labelSelector:
                matchExpressions:
                - key: k8s-app
                  operator: In
                  values:
                  - kube-dns 
EOF
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

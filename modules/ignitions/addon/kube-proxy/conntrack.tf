# remove with update to 1.15 https://github.com/kubernetes/kubernetes/pull/74840
# hotfix for https://kubernetes.io/blog/2019/03/29/kube-proxy-subtleties-debugging-an-intermittent-connection-reset/

data "ignition_file" "module_ip_conf" {
  mode = 420
  path = "/etc/modules-load.d/ip.conf"

  content {
    content = "ip_conntrack"
  }
}

data "ignition_file" "sysctl_ip_conf" {
  mode = 420
  path = "/etc/sysctl.d/ip.conf"

  content {
    content = "net.netfilter.ip_conntrack_tcp_be_liberal=1"
  }
}

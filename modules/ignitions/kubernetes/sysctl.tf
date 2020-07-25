data "ignition_file" "sysctl_k8s_conf" {
  path       = "/etc/sysctl.d/k8s.conf"
  filesystem = "root"
  mode       = 420

  content {
    content = file("${path.module}/files/sysctl.d/k8s.conf")
  }
}

data "ignition_file" "sysctl_max_user_watches_conf" {
  path       = "/etc/sysctl.d/max-user-watches.conf"
  filesystem = "root"
  mode       = 420

  content {
    content = file("${path.module}/files/sysctl.d/max-user-watches.conf")
  }
}

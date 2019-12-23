output "systemd_units" {
  value = []
}

output "files" {
  value = [
    data.ignition_file.kube_proxy_yaml.rendered,
    data.ignition_file.module_ip_conf.rendered,
    data.ignition_file.sysctl_ip_conf.rendered
  ]
}

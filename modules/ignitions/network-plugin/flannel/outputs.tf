output "files" {
  value = [
    data.ignition_file.kube_flannel_yaml.rendered
  ]
}

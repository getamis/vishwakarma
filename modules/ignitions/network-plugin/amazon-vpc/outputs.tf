output "files" {
  value = [
    data.ignition_file.aws_vpc_cni_yaml.rendered,
    # data.ignition_file.calico_yaml.rendered
  ]
}

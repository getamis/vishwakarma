output "ubuntu_image_id" {
  value = data.aws_ami.ubuntu_bionic.image_id
}

output "coreos_image_id" {
  value = data.aws_ami.coreos.image_id
}

output "fedora_coreos_image_id" {
  value = data.aws_ami.fedora_coreos.image_id
}

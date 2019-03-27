output "max_user_watches_id" {
  value = "${data.ignition_file.max_user_watches.id}"
}

output "max_user_watches_rendered" {
  value = "${data.template_file.max_user_watches.rendered}"
}

output "locksmithd_service_id" {
  value = "${data.ignition_systemd_unit.locksmithd.id}"
}

output "docker_dropin_id" {
  value = "${data.ignition_systemd_unit.docker_dropin.id}"
}

output "docker_dropin_rendered" {
  value = "${data.template_file.docker_dropin.rendered}"
}

output "update_ca_certificates_dropin_id" {
  value = "${data.ignition_systemd_unit.update_ca_certificates_dropin.id}"
}

output "update_ca_certificates_dropin_rendered" {
  value = "${data.template_file.update_ca_certificates_dropin.rendered}"
}

output "ntp_dropin_id" {
  value = "${data.ignition_file.ntp_dropin.id}"
}

output "ntp_dropin_rendered" {
  value = "${data.template_file.ntp_dropin.rendered}"
}

output "client_ca_file_id" {
  value = "${data.ignition_file.client_ca_file.id}"
}

output "client_ca_file_rendered" {
  value = "${base64decode(var.certificate_authority_data)}"
}

output "kubeconfig_id" {
  value = "${data.ignition_file.kubeconfig.id}"
}

output "kubeconfig_rendered" {
  value = "${data.template_file.kubeconfig.rendered}"
}

output "heptio_authenticator_aws_id" {
  value = "${data.ignition_systemd_unit.heptio_authenticator_aws.id}"
}

output "heptio_authenticator_aws_rendered" {
  value = "${data.template_file.heptio_authenticator_aws.rendered}"
}

output "kubelet_env_id" {
  value = "${data.ignition_file.kubelet_env.id}"
}

output "kubelet_env_rendered" {
  value = "${data.template_file.kubelet_env.rendered}"
}

output "kubelet_service_id" {
  value = "${data.ignition_systemd_unit.kubelet.id}"
}

output "kubelet_service_rendered" {
  value = "${data.template_file.kubelet.rendered}"
}

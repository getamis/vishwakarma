module "ignition_worker" {
  source = "../ignition"

  aws_region                   = "${var.aws_region}"
  container_images             = "${var.container_images}"
  bootstrap_upgrade_cl         = "${var.bootstrap_upgrade_cl}"
  ntp_servers                  = "${var.ntp_servers}"
  kubelet_node_label           = "${var.kubelet_node_label}"
  cloud_provider               = "${var.cloud_provider}"
  image_re                     = "${var.image_re}"
  client_ca_file               = "${var.client_ca_file}"
  cluster_name                 = "${var.cluster_name}"
  cluster_endpoint             = "${var.cluster_endpoint}"
  certificate_authority_data   = "${var.certificate_authority_data}"
  heptio_authenticator_aws_url = "${var.heptio_authenticator_aws_url}"
}

data "ignition_config" "main" {
  files = ["${compact(list(
    module.ignition_worker.max_user_watches_id,
    module.ignition_worker.ntp_dropin_id,
    module.ignition_worker.client_ca_file_id,
    module.ignition_worker.kubeconfig_id,
    module.ignition_worker.kubelet_env_id,
   ))}"
  ]

  systemd = [
    "${module.ignition_worker.locksmithd_service_id}",
    "${module.ignition_worker.docker_dropin_id}",
    "${module.ignition_worker.update_ca_certificates_dropin_id}",
    "${module.ignition_worker.heptio_authenticator_aws_id}",
    "${module.ignition_worker.kubelet_service_id}",
  ]
}

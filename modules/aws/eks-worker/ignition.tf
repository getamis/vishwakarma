
module "ignition_aws_iam_authenticator" {
  source                    = "../../ignitions/aws-iam-auth-worker"
  aws_iam_authenticator_url = "${var.aws_iam_authenticator_url}"
}


module "ignition_cni" {
  source          = "../../ignitions/cni"
}

module "ignition_docker" {
  source = "../../ignitions/docker"
}

module "ignition_kubeconfig" {
  source                     = "../../ignitions/eks-kube-config"
  cluster_name               = "${data.aws_eks_cluster.vishwakarma.id}"
  cluster_endpoint           = "${data.aws_eks_cluster.vishwakarma.endpoint}"
  certificate_authority_data = "${data.aws_eks_cluster.vishwakarma.certificate_authority.0.data}"
}

module "ignition_kubelet" {
  source = "../../ignitions/eks-kubelet"
  aws_region = "${var.aws_region}"
  instance_type       = "${var.worker_config["ec2_type_1"]}"
  certificate_authority_data = "${data.aws_eks_cluster.vishwakarma.certificate_authority.0.data}"
  hyperkube_image_tag = "v${var.kubernetes_version}"

  kubelet_flag_node_labels = "${join(",", compact(concat(
    list("node-role.kubernetes.io/${var.worker_config["name"]}"),
    var.kube_node_labels,
  )))}"

  kubelet_flag_register_with_taints = "${join(",", var.kube_node_taints)}"
  kubelet_flag_extra_flags          = "${var.kubelet_flag_extra_flags}"
}

module "ignition_locksmithd" {
  source          = "../../ignitions/locksmithd"
  reboot_strategy = "${var.reboot_strategy}"
}

module "ignition_max_user_watches" {
    source = "../../ignitions/max-user-watches"
}

module "ignition_ntp" {
  source = "../../ignitions/ntp"
  ntp_servers = "${var.ntp_servers}"
}

module "ignition_update_ca_certificates" {
  source = "../../ignitions/update-ca-certificates"
}


data "ignition_config" "main" {
  files = ["${compact(concat(
    module.ignition_aws_iam_authenticator.files,
    module.ignition_cni.files,
    module.ignition_docker.files,
    module.ignition_kubeconfig.files,
    module.ignition_kubelet.files,
    module.ignition_locksmithd.files,
    module.ignition_max_user_watches.files,
    module.ignition_ntp.files,
    module.ignition_update_ca_certificates.files,
    var.extra_ignition_file_ids,
  ))}"]

  systemd = ["${compact(concat(
    module.ignition_aws_iam_authenticator.systemd_units,
    module.ignition_docker.systemd_units,
    module.ignition_cni.systemd_units,
    module.ignition_kubeconfig.systemd_units,
    module.ignition_kubelet.systemd_units,
    module.ignition_locksmithd.systemd_units,
    module.ignition_max_user_watches.systemd_units,
    module.ignition_ntp.systemd_units,
    module.ignition_update_ca_certificates.systemd_units,
    var.extra_ignition_systemd_unit_ids,
  ))}"]
}

resource "aws_s3_bucket_object" "ignition" {
  bucket  = "${var.s3_bucket}"
  key     = "ign-worker-${var.worker_config["name"]}.json"
  content = "${data.ignition_config.main.rendered}"
  acl     = "private"

  server_side_encryption = "AES256"

  tags = "${merge(map(
      "Name", "ign-worker-${var.worker_config["name"]}.json",
      "Role", "worker",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
    ), var.extra_tags)}"
}

data "ignition_config" "s3" {
  replace {
    source       = "${format("s3://%s/%s", var.s3_bucket, aws_s3_bucket_object.ignition.key)}"
    verification = "sha512-${sha512(data.ignition_config.main.rendered)}"
  }
}

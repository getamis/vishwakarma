data "template_file" "max_user_watches" {
  template = "${file("${path.module}/resources/sysctl.d/max-user-watches.conf")}"
}

data "ignition_file" "max_user_watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/10-max-user-watches.conf"
  mode       = 0644

  content {
    content = "${data.template_file.max_user_watches.rendered}"
  }
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "template_file" "docker_dropin" {
  template = "${file("${path.module}/resources/dropins/10-dockeropts.conf")}"
}

data "ignition_systemd_unit" "docker_dropin" {
  name    = "docker.service"
  enabled = true

  dropin = [
    {
      name    = "10-dockeropts.conf"
      content = "${data.template_file.docker_dropin.rendered}"
    },
  ]
}

data "template_file" "update_ca_certificates_dropin" {
  template = "${file("${path.module}/resources/dropins/10-always-update-ca-certificates.conf")}"
}

data "ignition_systemd_unit" "update_ca_certificates_dropin" {
  name    = "update-ca-certificates.service"
  enabled = true

  dropin = [
    {
      name    = "10-always-update-ca-certificates.conf"
      content = "${data.template_file.update_ca_certificates_dropin.rendered}"
    },
  ]
}

data "template_file" "ntp_dropin" {
  template = "${file("${path.module}/resources/dropins/10-timesyncd.conf")}"

  vars {
    ntp_servers = "${join(" ", var.ntp_servers)}"
  }
}

data "ignition_file" "ntp_dropin" {
  path       = "/etc/systemd/timesyncd.conf.d/10-installer.conf"
  filesystem = "root"
  mode       = 0644

  content {
    content = "${data.template_file.ntp_dropin.rendered}"
  }
}

data "ignition_file" "client_ca_file" {
  path       = "${var.client_ca_file}"
  filesystem = "root"
  mode       = 0644

  content {
    content = "${base64decode(var.certificate_authority_data)}"
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubernetes/kubeconfig")}"

  vars {
    cluster_name          = "${var.cluster_name}"
    cluster_endpoint      = "${var.cluster_endpoint}"
    certificate_authority = "${var.client_ca_file}"
  }
}

data "ignition_file" "kubeconfig" {
  path       = "/var/lib/kubelet/kubeconfig"
  filesystem = "root"
  mode       = 0644

  content {
    content = "${data.template_file.kubeconfig.rendered}"
  }
}

data "template_file" "heptio_authenticator_aws" {
  template = "${file("${path.module}/resources/services/heptio-authenticator-aws.service")}"

  vars {
    heptio_authenticator_aws_url = "${var.heptio_authenticator_aws_url}"
  }
}

data "ignition_systemd_unit" "heptio_authenticator_aws" {
  name    = "heptio-authenticator-aws.service"
  enabled = true
  content = "${data.template_file.heptio_authenticator_aws.rendered}"
}

data "template_file" "kubelet_env" {
  template = "${file("${path.module}/resources/kubernetes/kubelet.env")}"

  vars {
    kubelet_image_url = "${replace(var.container_images["hyperkube"],var.image_re,"$1")}"
    kubelet_image_tag = "${replace(var.container_images["hyperkube"],var.image_re,"$2")}"
  }
}

data "ignition_file" "kubelet_env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = 0644

  content {
    content = "${data.template_file.kubelet_env.rendered}"
  }
}

data "template_file" "kubelet" {
  template = "${file("${path.module}/resources/services/kubelet.service")}"

  vars {
    cloud_provider            = "${var.cloud_provider}"
    node_label                = "${var.kubelet_node_label}"
    pod_infra_container_image = "${replace(var.container_images["pause_amd64"], "REGION", var.aws_region)}"
    client_ca_file            = "${var.client_ca_file}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = "${data.template_file.kubelet.rendered}"
}

module "ignition_admin_kubeconfig" {
  source = "../../ignitions/kubeconfig"

  config_path = "/etc/kubernetes/admin.conf"

  cluster  = var.name
  context  = "kubernetes-admin@kubernetes"
  user     = "kubernetes-admin"
  endpoint = "https://${aws_elb.master_internal.dns_name}:${var.apiserver_secure_port}"

  certificates = {
    ca_cert     = module.kubernetes_ca.cert_pem
    client_cert = module.admin_cert.cert_pem
    client_key  = module.admin_cert.private_key_pem
  }
}

module "ignition_controller_manager_kubeconfig" {
  source = "../../ignitions/kubeconfig"

  config_path = "/opt/kubernetes/controller-manager.conf.tpl"

  cluster  = var.name
  context  = "system:kube-controller-manager@kubernetes"
  user     = "system:kube-controller-manager"
  endpoint = "https://$${HOST_IP}:${var.apiserver_secure_port}"

  certificates = {
    ca_cert     = module.kubernetes_ca.cert_pem
    client_cert = module.controller_manager_cert.cert_pem
    client_key  = module.controller_manager_cert.private_key_pem
  }
}

module "ignition_scheduler_kubeconfig" {
  source = "../../ignitions/kubeconfig"

  config_path = "/opt/kubernetes/scheduler.conf.tpl"

  cluster  = var.name
  context  = "system:kube-scheduler@kubernetes"
  user     = "system:kube-scheduler"
  endpoint = "https://$${HOST_IP}:${var.apiserver_secure_port}"

  certificates = {
    ca_cert     = module.kubernetes_ca.cert_pem
    client_cert = module.scheduler_cert.cert_pem
    client_key  = module.scheduler_cert.private_key_pem
  }
}

module "ignition_kubelet_kubeconfig_tpl" {
  source = "../../ignitions/kubeconfig"

  config_path = "/opt/kubernetes/kubelet.conf.tpl"

  cluster  = var.name
  context  = "system:node:$${HOSTNAME}@kubernetes"
  user     = "system:node:$${HOSTNAME}"
  endpoint = "https://$${HOST_IP}:${var.apiserver_secure_port}"

  certificates = {
    ca_cert          = module.kubernetes_ca.cert_pem
    client_cert_path = "/var/lib/kubelet/pki/kubelet-client-current.pem"
    client_key_path  = "/var/lib/kubelet/pki/kubelet-client-current.pem"
  }
}

resource "aws_s3_bucket_object" "kubeconfig" {
  bucket  = var.s3_bucket
  key     = "kubeconfig"
  content = module.ignition_admin_kubeconfig.content
  acl     = "private"

  server_side_encryption = "AES256"
  content_type           = "text/plain"

  tags = merge(var.extra_tags, map(
    "Name", "kubeconfig",
    "kubernetes.io/cluster/${var.name}", "owned",
    "Role", "k8s-master"
  ))
}
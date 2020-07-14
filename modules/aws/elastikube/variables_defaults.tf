locals {
  container = merge({
    hyperkube = {
      repo = "gcr.io/google-containers/hyperkube-amd64"
      tag  = var.kubernetes_version
    }
    etcd = {
      repo = "quay.io/coreos/etcd"
      tag  = "v3.4.5"
    }
  }, var.container)
}

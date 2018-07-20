variable "pod_checkpointer" {
  type = "map"

  default = {
    image_path = "quay.io/coreos/pod-checkpointer"
    image_tag  = "e22cc0e3714378de92f45326474874eb602ca0ac"
  }

  description = "The hyperkube container image path and tag"
}

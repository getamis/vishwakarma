KUBELET_IMAGE_REPO="${kubelet_image_repo}"
KUBELET_IMAGE_TAG="${kubelet_image_tag}"
CFSSL_IMAGE_REPO="${cfssl_image_repo}"
CFSSL_IMAGE_TAG="${cfssl_image_tag}"
KUBELET_CLOUD_PROVIDER="${kubelet_cloud_provider}"
KUBELET_NETWORK_PLUGIN="${network_plugin}"
KUBELET_CLOUD_PROVIDER_ARGS="${kubelet_cloud_provider_flag} ${kubelet_cloud_config_path_flag}"
KUBELET_EXTRA_ARGS="%{ for flag, value in extra_flags ~}%{ if value != "" ~} --${flag}=${value} %{ endif ~}%{ endfor ~}"
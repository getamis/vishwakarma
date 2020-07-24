[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=${bootstrap_kubeconfig} --kubeconfig=${kubeconfig}"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni"
EnvironmentFile=-/etc/default/kubernetes.env
EnvironmentFile=-/var/lib/kubelet/kubelet-flags.env
ExecStart=
ExecStart=/opt/kubernetes/bin/kubelet-wrapper $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_NETWORK_ARGS $KUBELET_CLOUD_PROVIDER_ARGS $KUBELET_EXTRA_ARGS
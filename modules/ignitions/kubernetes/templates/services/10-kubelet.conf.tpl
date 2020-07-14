[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=${bootstrap_kubeconfig} --kubeconfig=${kubeconfig}"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni"
EnvironmentFile=-/var/lib/kubelet/kubelet.env
ExecStartPre=/opt/kubernetes/bin/get-instance-info.sh
Environment="KUBELET_HOST_ARGS=--node-ip=$${HOST_IP} --hostname-override=$${HOSTNAME}"
ExecStart=
ExecStart=/opt/kubernetes/bin/hyperkube kubelet $$KUBELET_KUBECONFIG_ARGS $$KUBELET_CONFIG_ARGS $$KUBELET_NETWORK_ARGS $$KUBELET_CLOUD_PROVIDER_ARGS $$KUBELET_HOST_ARGS $$KUBELET_EXTRA_ARGS
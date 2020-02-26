[Unit]
Description=Kubelet via Hyperkube ACI
Requires=network-online.target

[Service]
EnvironmentFile=/etc/kubernetes/kubelet.env

ExecStartPre=/usr/bin/bash -c "grep 'certificate-authority-data' /etc/kubernetes/kubeconfig | awk '{print $2}' | base64 -d > /etc/kubernetes/ca.crt"

ExecStart=/opt/kubelet/kubelet-wrapper.sh \
  --kubeconfig=/etc/kubernetes/kubeconfig \
  --cni-conf-dir=/etc/cni/net.d \
  --network-plugin=cni \
  --lock-file=/var/run/lock/kubelet.lock \
  --exit-on-lock-contention \
  --anonymous-auth=false \
  --client-ca-file=/etc/kubernetes/ca.crt \
  --cluster-domain=cluster.local \
  ${kubelet_flag_cloud_provider} \
  ${kubelet_flag_node_labels} \
  ${kubelet_flag_register_with_taints} \
  ${kubelet_flag_cni_bin_dir} \
  ${kubelet_flag_cluster_dns} \
  ${kubelet_flag_cloud_provider} \
  ${kubelet_flag_extra_flags} \
  ${kubelet_flag_allow_privileged} \
  ${kubelet_flag_pod_manifest_path}

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
RequiredBy=kube-addon.service

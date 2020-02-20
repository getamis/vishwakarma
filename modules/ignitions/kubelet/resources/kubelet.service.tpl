[Unit]
Description=Kubelet via Hyperkube ACI
Wants=rpc-statd.service

[Service]
EnvironmentFile=/etc/kubernetes/kubelet.env
Environment="RKT_RUN_ARGS=--uuid-file-save=/var/cache/kubelet-pod.uuid \
  --volume=resolv,kind=host,source=/etc/resolv.conf \
  --mount volume=resolv,target=/etc/resolv.conf \
  --volume cni-bin,kind=host,source=/opt/cni/bin \
  --mount volume=cni-bin,target=/opt/cni/bin \
  --volume cni-config,kind=host,source=/etc/cni/net.d \
  --mount volume=cni-config,target=/etc/cni/net.d \
  --volume var-log,kind=host,source=/var/log \
  --mount volume=var-log,target=/var/log"

ExecStartPre=/bin/mkdir -p /etc/kubernetes/manifests
ExecStartPre=/bin/mkdir -p /srv/kubernetes/manifests
ExecStartPre=/bin/mkdir -p /etc/kubernetes/checkpoint-secrets
ExecStartPre=/bin/mkdir -p /etc/cni/net.d
ExecStartPre=/bin/mkdir -p /opt/cni/bin

ExecStartPre=/usr/bin/sh -c "/usr/bin/systemctl set-environment HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname | cut -d '.' -f 1)"
ExecStartPre=/usr/bin/sh -c "/usr/bin/systemctl set-environment HOST_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
ExecStartPre=/usr/bin/bash -c "grep 'certificate-authority-data' /etc/kubernetes/kubeconfig | awk '{print $2}' | base64 -d > /etc/kubernetes/ca.crt"
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/cache/kubelet-pod.uuid
${ network_plugin == "amazon-vpc" ? "ExecStartPre=/usr/bin/sh -c /etc/kubernetes/get-max-pods.sh" : ""}

ExecStart=/usr/lib/coreos/kubelet-wrapper \
  --kubeconfig=/etc/kubernetes/kubeconfig \
  --cni-conf-dir=/etc/cni/net.d \
  --network-plugin=cni \
  --lock-file=/var/run/lock/kubelet.lock \
  --exit-on-lock-contention \
  --anonymous-auth=false \
  --client-ca-file=/etc/kubernetes/ca.crt \
  --cluster-domain=cluster.local \
  --node-ip=$${HOST_IP} \
  --hostname-override=$${HOSTNAME} \
  ${ network_plugin == "amazon-vpc" ? "--max-pods=$${MAX_PODS}" : ""} \
  ${kubelet_flag_cloud_provider} \
  ${kubelet_flag_node_labels} \
  ${kubelet_flag_register_with_taints} \
  ${kubelet_flag_cni_bin_dir} \
  ${kubelet_flag_cluster_dns} \
  ${kubelet_flag_cloud_provider} \
  ${kubelet_flag_extra_flags} \
  ${kubelet_flag_allow_privileged} \
  ${kubelet_flag_pod_manifest_path}

ExecStop=-/usr/bin/rkt stop --uuid-file=/var/cache/kubelet-pod.uuid

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
RequiredBy=kube-addon.service

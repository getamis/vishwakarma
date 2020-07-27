[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=rpc-statd.service
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/opt/kubernetes/bin/kubelet-wrapper

Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
RequiredBy=kubeinit-addons.service
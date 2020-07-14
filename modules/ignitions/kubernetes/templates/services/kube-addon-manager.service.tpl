[Unit]
Description=Kubernetes Addon Manager
After=kubelet.service

[Service]
Type=simple
RemainAfterExit=true

ExecStartPre=/usr/bin/mkdir -p ${addons_path}
ExecStart=/usr/bin/docker run --rm \
    -v /etc/kubernetes/admin.conf:/etc/kubernetes/admin.conf \
    -v ${addons_path}:${addons_path} \
    -e KUBECONFIG=/etc/kubernetes/admin.conf \
    --network=host \
    ${image} \
      kubectl apply -f ${addons_path}

Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target

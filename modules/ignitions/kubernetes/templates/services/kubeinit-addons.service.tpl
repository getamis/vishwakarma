[Unit]
Description=Systemd unit for initing Kubernetes resources
After=kubelet.service

[Service]
Type=simple
RemainAfterExit=true

EnvironmentFile=-/etc/default/kubernetes.env
Environment="ADDONS_PATH=${path}"
ExecStart=/opt/kubernetes/bin/init-addons.sh
      
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target

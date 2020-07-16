[Unit]
Description=Kubernetes Addon Manager
After=kubelet.service

[Service]
Type=simple
RemainAfterExit=true

ExecStartPre=/usr/bin/mkdir -p ${path}
Environment="PATH=/opt/bin:/opt/kubernetes/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
Environment="KUBECONFIG=/etc/kubernetes/admin.conf"
ExecStart=/opt/kubernetes/bin/kubectl apply -f ${path}
      
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target

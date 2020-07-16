[Unit]
Description = Systemd unit for installing Kubernetes
ConditionPathExists = !/opt/kubernetes/install.done
Before = kubelet.service
After = network.target

[Service]
Type=oneshot
RemainAfterExit=true

User=root
Group=root

EnvironmentFile=-/etc/default/kubernetes.env
ExecStart=/opt/kubernetes/bin/install.sh
ExecStartPost=/bin/touch /opt/kubernetes/install.done

[Install]
WantedBy=multi-user.target
RequiredBy=kubelet.service

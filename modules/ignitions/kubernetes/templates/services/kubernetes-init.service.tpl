[Unit]
Description = Systemd unit for initing Kubernetes
ConditionPathExists = !/opt/kubernetes/init.done
Before = kubelet.service
After = network.target

[Service]
Type=oneshot
RemainAfterExit=true

User=root
Group=root

Environment="PATH=/opt/bin:/opt/kubernetes/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
EnvironmentFile=-/etc/default/kubernetes.env
ExecStart=/opt/kubernetes/bin/init.sh
ExecStartPost=/bin/touch /opt/kubernetes/init.done

[Install]
WantedBy = multi-user.target
RequiredBy = kubelet.service

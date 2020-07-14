[Unit]
Description = Systemd unit for initing kubelet
ConditionPathExists = !/opt/kubernetes/kubelet-init.done
Before = kubelet.service
After = network.target

[Service]
Type = oneshot
RemainAfterExit = true

User = root
Group = root

Environment="PATH=/opt/bin:/opt/kubernetes/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
ExecStart=/opt/kubernetes/bin/kubelet-init.sh
ExecStartPost=/bin/touch /opt/kubernetes/kubelet-init.done

[Install]
WantedBy = multi-user.target
RequiredBy = kubelet.service

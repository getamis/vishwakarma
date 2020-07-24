[Unit]
Description=etcd service
Requires=network-online.target

[Service]
Environment="PATH=/opt/bin:/opt/etcd/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
EnvironmentFile=/etc/etcd/etcd.env
ExecStartPre=-/usr/bin/docker rm -f etcd
ExecStart=/opt/etcd/bin/etcd-wrapper.sh
ExecStop=-/usr/bin/docker stop etcd

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
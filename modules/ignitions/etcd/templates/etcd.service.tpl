[Unit]
Description=etcd service
Requires=network-online.target

[Service]
EnvironmentFile=/etc/etcd/etcd.env

ExecStartPre=-/usr/bin/docker rm -f etcd
ExecStart=/opt/etcd/etcd-wrapper.sh
ExecStop=-/usr/bin/docker stop etcd

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
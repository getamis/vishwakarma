[Unit]
Description = Systemd unit for fetching Prometheus Node Exporter
ConditionPathExists = !/opt/node-exporter.done
Before = node-exporter.service
After = network.target

[Service]
Type = oneshot
RemainAfterExit = true

User = root
Group = root

ExecStartPre = /usr/bin/mkdir -p /opt
ExecStartPre = /usr/bin/wget -q -O node_exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.linux-amd64.tar.gz
ExecStartPre = /usr/bin/tar zxf node_exporter.tar.gz
ExecStart = /usr/bin/cp node_exporter-${version}.linux-amd64/node_exporter /opt/node_exporter
ExecStartPost = /bin/touch /opt/node-exporter.done
ExecStartPost = /usr/bin/rm node_exporter.tar.gz
ExecStartPost = /usr/bin/rm -r node_exporter-${version}.linux-amd64

[Install]
WantedBy = multi-user.target
RequiredBy = node-exporter.service

[Unit]
Description = Systemd unit for Prometheus Node Exporter
After = network.target node-exporter-fetcher.service


[Service]
Type = simple
User = root
RemainAfterExit=true

ExecStart = /opt/node_exporter \
  --web.listen-address=${listen_address} \
  --web.telemetry-path=/metrics \
  --log.level=info \
  --log.format=logger:stdout \
  --collector.textfile.directory=/var/lib/node_exporter/textfile_collector \
  --collector.netdev.ignored-devices='^(weave|veth.*|docker0|datapath|dummy0)$' \
  --collector.filesystem.ignored-mount-points='^/(sys|proc|dev|host|etc|var/lib/docker|run|var/lib/lxcfs|var/lib/kubelet)($|/)' \
  --collector.diskstats \
  --collector.filefd \
  --collector.filesystem \
  --collector.interrupts \
  --collector.loadavg \
  --collector.mdadm \
  --collector.meminfo \
  --collector.netdev \
  --collector.netstat \
  --collector.sockstat \
  --collector.stat \
  --collector.tcpstat \
  --collector.textfile \
  --collector.time \
  --collector.uname \
  --collector.vmstat

WorkingDirectory = /
Restart = on-failure
RestartSec = 30s

[Install]
WantedBy = multi-user.target

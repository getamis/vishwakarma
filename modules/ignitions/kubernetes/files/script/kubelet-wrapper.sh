#!/bin/bash
# Wrapper script for launching kubelet.

set -eu

source /opt/kubernetes/bin/get-host-info.sh

sudo sysctl --system

set -x
KUBELET_EXEC=${KUBELET_EXEC:-"/opt/kubernetes/bin/kubelet"}
exec ${KUBELET_EXEC} \
  --node-ip=${HOST_IP} \
  --hostname-override=${HOSTNAME} \
  "$@"
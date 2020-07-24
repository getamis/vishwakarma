#!/bin/bash
# Wrapper script for initing Kubernetes resources.

set -eu

mkdir -p ${ADDONS_PATH}

source /opt/kubernetes/bin/get-host-info.sh
export KUBECONFIG=/etc/kubernetes/admin.conf

set -x
KUBECTL_EXEC=${KUBECTL_EXEC:-"/opt/kubernetes/bin/kubectl"}
${KUBECTL_EXEC} label node ${HOSTNAME_FQDN} node-role.kubernetes.io/master="" --overwrite
${KUBECTL_EXEC} apply -f ${ADDONS_PATH}
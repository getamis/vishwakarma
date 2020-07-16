#!/bin/bash
# Wrapper script for initing Kubernetes resources.

set -eu

mkdir -p ${ADDONS_PATH}

source /opt/kubernetes/bin/get-host-info.sh
export KUBECONFIG=/etc/kubernetes/admin.conf

/opt/kubernetes/bin/kubectl \
  label node ${HOSTNAME_FQDN} node-role.kubernetes.io/master="" --overwrite

/opt/kubernetes/bin/kubectl apply -f ${ADDONS_PATH}
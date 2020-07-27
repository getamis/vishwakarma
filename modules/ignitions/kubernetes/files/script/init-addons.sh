#!/bin/bash
# Wrapper script for initing Kubernetes resources.

set -eu

function require_ev_all() {
	for rev in $@ ; do
		if [[ -z "${!rev}" ]]; then
			echo "${rev}" is not set
			exit 1
		fi
	done
}

require_ev_all KUBECTL_IMAGE_REPO KUBECTL_IMAGE_TAG
KUBECTL_IMAGE="${KUBECTL_IMAGE_REPO}:${KUBECTL_IMAGE_TAG}"

mkdir -p ${ADDONS_PATH}

source /opt/kubernetes/bin/get-host-info.sh
export KUBECONFIG=/etc/kubernetes/admin.conf

set -x
docker run --rm \
  -v /etc/kubernetes/admin.conf:/root/.kube/config:ro \
  --entrypoint=kubectl ${KUBECTL_IMAGE} label node ${HOSTNAME_FQDN} node-role.kubernetes.io/master="" --overwrite

docker run --rm \
  -v /etc/kubernetes/admin.conf:/root/.kube/config:ro \
  -v ${ADDONS_PATH}:${ADDONS_PATH}:ro \
  --entrypoint=kubectl ${KUBECTL_IMAGE} apply -f ${ADDONS_PATH}
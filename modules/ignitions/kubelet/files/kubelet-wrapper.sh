#!/bin/bash
# Wrapper script for launching kubelet.
#
# Make sure to set KUBELET_IMAGE_TAG to an image tag published here:
# https://quay.io/repository/coreos/hyperkube?tab=tags Alternatively,
# override KUBELET_IMAGE to a custom image.

set -e

function require_ev_all() {
	for rev in $@ ; do
		if [[ -z "${!rev}" ]]; then
			echo "${rev}" is not set
			exit 1
		fi
	done
}

function require_ev_one() {
	for rev in $@ ; do
		if [[ ! -z "${!rev}" ]]; then
			return
		fi
	done
	echo One of $@ must be set
	exit 1
}

KUBELET_IMAGE_TAG="${KUBELET_IMAGE_TAG:-${KUBELET_VERSION}}"

require_ev_one KUBELET_IMAGE KUBELET_IMAGE_TAG

KUBELET_IMAGE_URL="${KUBELET_IMAGE_URL:-${KUBELET_ACI:-quay.io/coreos/hyperkube}}"
KUBELET_IMAGE="${KUBELET_IMAGE:-${KUBELET_IMAGE_URL}:${KUBELET_IMAGE_TAG}}"

DOCKER="${DOCKER:-/usr/bin/docker}"

mkdir -p /etc/kubernetes
mkdir -p /etc/kubernetes/manifests
mkdir -p /etc/kubernetes/checkpoint-secrets
mkdir -p /etc/cni/net.d
mkdir -p /opt/cni/bin
mkdir -p /var/lib/docker
mkdir -p /var/lib/kubelet
mkdir -p /run/kubelet

# Copy binaries to host
UPDATE_HYPERKUBE=false
if [[ ! -f /opt/kubelet/hyperkube ]]; then 
  UPDATE_HYPERKUBE=true
else
  HYPERKUBE_VERSION=$(/opt/kubelet/hyperkube kubectl version --client --short | grep -o 'v[0-9].[0-9]*.[0-9]*')
  if [[ ${HYPERKUBE_VERSION} != ${KUBELET_IMAGE_TAG} ]]; then 
    UPDATE_HYPERKUBE=true
  fi
fi

if [[ ${UPDATE_HYPERKUBE} == "true" ]]; then
  ${DOCKER} run --rm \
    -v /opt/cni:/tmp/cni \
    -v /opt/kubelet:/tmp/kubelet \
    ${KUBELET_IMAGE_URL}:${KUBELET_IMAGE_TAG} \
      /bin/bash -c "cp -rp /opt/cni/bin/ /tmp/cni; cp -rp /hyperkube /tmp/kubelet/hyperkube"
fi

HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname | cut -d '.' -f 1)
HOST_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Set MAX_PODS
source /opt/kubelet/get-max-pods.sh

KUBELET_EXEC_ARGS=${KUBELET_EXEC_ARGS:-"/opt/kubelet/hyperkube kubelet"}
set -x
# Run kubelet on container
exec ${KUBELET_EXEC_ARGS} \
  --node-ip=${HOST_IP} \
  --hostname-override=${HOSTNAME} \
  --max-pods=${MAX_PODS} \
  "$@"
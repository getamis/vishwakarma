#!/bin/bash
# Wrapper for launching etcd via docker.

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

require_ev_one ETCD_IMAGE ETCD_IMAGE_TAG

ETCD_IMAGE_REPO="${ETCD_IMAGE_REPO:-${ETCD_ACI:-quay.io/coreos/etcd}}"
ETCD_IMAGE="${ETCD_IMAGE:-${ETCD_IMAGE_REPO}:${ETCD_IMAGE_TAG}}"

if [[ ! -e "${ETCD_DATA_DIR}" ]]; then
	mkdir -p ${ETCD_DATA_DIR}
	chown "${USER_ID}:${USER_ID}" "${ETCD_DATA_DIR}"
  INITIAL_CLUSTER_STATE=new
else
  INITIAL_CLUSTER_STATE=existing
fi

DOCKER_RUN_ARGS="${DOCKER_RUN_ARGS} ${DOCKER_OPTS}"

if [[ $CLOUD_PROVIDER == "aws" ]]; then 
  export HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname | cut -d '.' -f 1)
  export HOST_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
fi

[[ ! -n "$HOSTNAME" ]] && export HOSTNAME=$(hostname)
[[ ! -n "$HOST_IP" ]] && export HOST_IP=$(ip -o route get 8.8.8.8 | sed -e 's/^.* src \([^ ]*\) .*$/\1/')

DOCKER="${DOCKER:-/usr/bin/docker}"
ETCD_EXEC_ARGS=${ETCD_EXEC_ARGS:-etcd}
set -x
exec ${DOCKER} run \
  -v ${ETCD_DATA_DIR}:${ETCD_DATA_DIR}:rw \
  -v /etc/ssl/certs:/etc/ssl/certs:ro \
  -v ${ETCD_CERT_PATH}:${ETCD_CERT_PATH}:rw \
  -v /usr/share/ca-certificates:/usr/share/ca-certificates:ro \
  -v /etc/hosts:/etc/hosts:ro \
  --env-file=/etc/etcd/etcd.env \
  --net=host \
  --pid=host \
  --user=${USER_ID} \
  --name=etcd \
  ${DOCKER_RUN_ARGS} \
  ${ETCD_IMAGE} \
    ${ETCD_EXEC_ARGS} \
      --name=${HOSTNAME} \
      --advertise-client-urls=${SCHEME}://${HOST_IP}:${CLIENT_PORT} \
      --initial-advertise-peer-urls=${SCHEME}://${HOST_IP}:${PEER_PORT} \
      --initial-cluster-state=${INITIAL_CLUSTER_STATE} \
      "$@"
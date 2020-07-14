#!/bin/bash
# Wrapper script for initing kubelet.

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

source /opt/kubernetes/bin/get-instance-info.sh

require_ev_all KUBELET_IMAGE_REPO KUBELET_IMAGE_TAG
require_ev_all CFSSL_IMAGE_REPO CFSSL_IMAGE_TAG

KUBELET_IMAGE="${KUBELET_IMAGE_REPO}:${KUBELET_IMAGE_TAG}"
CFSSL_IMAGE="${CFSSL_IMAGE_REPO}:${CFSSL_IMAGE_TAG}"

DOCKER_EXEC="${DOCKER_EXEC:-/usr/bin/docker}"

mkdir -p /opt/kubernetes
mkdir -p /opt/kubernetes/bin
mkdir -p /etc/kubernetes
mkdir -p /etc/kubernetes/manifests
mkdir -p /etc/kubernetes/pki
mkdir -p /etc/cni/net.d
mkdir -p /opt/cni/bin
mkdir -p /var/lib/kubelet
mkdir -p /var/lib/kubelet/pki
mkdir -p /run/kubelet

# Copy binaries to host
UPDATE_HYPERKUBE=false
if [[ ! -f /opt/kubernetes/bin/hyperkube ]]; then 
  UPDATE_HYPERKUBE=true
else
  HYPERKUBE_VERSION=$(/opt/kubernetes/bin/hyperkube kubectl version --client --short | grep -o 'v[0-9].[0-9]*.[0-9]*')
  if [[ ${HYPERKUBE_VERSION} != ${KUBELET_IMAGE_TAG} ]]; then 
    UPDATE_HYPERKUBE=true
  fi
fi

if [[ ${UPDATE_HYPERKUBE} == "true" ]]; then
  ${DOCKER_EXEC} run --rm \
    -v /opt/cni:/tmp/cni \
    -v /opt/kubernetes/bin:/tmp/bin \
    ${KUBELET_IMAGE} \
      /bin/bash -c "cp -rp /opt/cni/bin/ /tmp/cni; cp -rp /hyperkube /tmp/bin/hyperkube"
fi

APISERVER_YAML_SRC="/opt/kubernetes/kube-apiserver.yaml.tpl"
APISERVER_YAML_DEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
if test -f ${APISERVER_YAML_SRC} && ! test -f ${APISERVER_YAML_DEST}; then 
  envsubst < ${APISERVER_YAML_SRC} > ${APISERVER_YAML_DEST}
fi

PROXY_CM_YAML_SRC="/opt/kubernetes/kube-proxy-cm.yaml.tpl"
PROXY_CM_YAML_DEST="/etc/kubernetes/addons/kube-proxy-cm.yaml"
if test -f ${PROXY_CM_YAML_SRC} && ! test -f ${PROXY_CM_YAML_DEST}; then 
  envsubst < ${PROXY_CM_YAML_SRC} > ${PROXY_CM_YAML_DEST}
fi

CONTROLLER_MANAGER_CONFIG_SRC="/opt/kubernetes/controller-manager.conf.tpl"
CONTROLLER_MANAGER_CONFIG_DEST="/etc/kubernetes/controller-manager.conf"
if test -f ${CONTROLLER_MANAGER_CONFIG_SRC} && ! test -f ${CONTROLLER_MANAGER_CONFIG_DEST}; then 
  envsubst < ${CONTROLLER_MANAGER_CONFIG_SRC} > ${CONTROLLER_MANAGER_CONFIG_DEST}
fi

SCHEDULER_CONFIG_SRC="/opt/kubernetes/scheduler.conf.tpl"
SCHEDULER_CONFIG_DEST="/etc/kubernetes/scheduler.conf"
if test -f ${SCHEDULER_CONFIG_SRC} && ! test -f ${SCHEDULER_CONFIG_DEST}; then 
  envsubst < ${SCHEDULER_CONFIG_SRC} > ${SCHEDULER_CONFIG_DEST}
fi

KUBELET_CONFIG_SRC="/opt/kubernetes/kubelet.conf.tpl"
KUBELET_CONFIG_DEST="/etc/kubernetes/kubelet.conf"
if test -f ${KUBELET_CONFIG_SRC} && ! test -f ${KUBELET_CONFIG_DEST} ; then 
  envsubst < ${KUBELET_CONFIG_SRC} > ${KUBELET_CONFIG_DEST}
fi

KUBE_PKI_PATH="/etc/kubernetes/pki"
KUBELET_PKI_PATH="/var/lib/kubelet/pki"
CSR_FILE_SRC="/opt/kubernetes/kubelet-csr.json.tpl"
CSR_FILE_DEST="${KUBELET_PKI_PATH}/csr.json"

DATE=$(date +%Y-%m-%d)
FILE_NAME="kubelet-client-current.pem"
if test -f ${CSR_FILE_SRC} && ! test -f ${KUBELET_PKI_PATH}/${FILE_NAME} ; then 
  envsubst < ${CSR_FILE_SRC} > ${CSR_FILE_DEST}

  ${DOCKER_EXEC} run --rm \
  -v ${KUBELET_PKI_PATH}/:/tmp/pki \
  -v ${KUBE_PKI_PATH}/:/etc/kubernetes/pki/ \
  ${CFSSL_IMAGE} \
    /bin/sh -c "cfssl gencert -ca=${KUBE_PKI_PATH}/ca.crt -ca-key=${KUBE_PKI_PATH}/ca.key /tmp/pki/csr.json | cfssljson -bare /tmp/pki/kubelet-client"

  cat ${KUBELET_PKI_PATH}/kubelet-client.pem > ${KUBELET_PKI_PATH}/kubelet-client-${DATE}.pem
  cat ${KUBELET_PKI_PATH}/kubelet-client-key.pem >> ${KUBELET_PKI_PATH}/kubelet-client-${DATE}.pem

  ln -s ${KUBELET_PKI_PATH}/kubelet-client-${DATE}.pem ${KUBELET_PKI_PATH}/kubelet-client-current.pem

  rm -rf ${CSR_FILE_DEST} \
    ${KUBELET_PKI_PATH}/kubelet-client.csr \
    ${KUBELET_PKI_PATH}/kubelet-client.pem \
    ${KUBELET_PKI_PATH}/kubelet-client-key.pem
fi
#!/bin/bash
# Wrapper script for initing Kubernetes configs.

set -eu

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

source /opt/kubernetes/bin/get-host-info.sh

require_ev_all CFSSL_IMAGE_REPO CFSSL_IMAGE_TAG

CFSSL_IMAGE="${CFSSL_IMAGE_REPO}:${CFSSL_IMAGE_TAG}"
DOCKER_EXEC="${DOCKER_EXEC:-/usr/bin/docker}"

KUBE_OPT_PATH=${KUBE_OPT_PATH:="/opt/kubernetes"}
KUBE_ETC_PATH=${KUBE_ETC_PATH:="/etc/kubernetes"}
KUBELET_VAR_PATH=${KUBELET_VAR_PATH:="/var/lib/kubelet"}

OPT_BIN_PATH=${OPT_BIN_PATH:="${KUBE_OPT_PATH}/bin"}
CNI_BIN_PATH=${CNI_BIN_PATH:="/opt/cni/bin"}
CNI_CONFIG_PATH=${CNI_CONFIG_PATH:="/etc/cni/net.d"}

mkdir -p ${KUBE_OPT_PATH}
mkdir -p ${OPT_BIN_PATH}
mkdir -p ${CNI_BIN_PATH}
mkdir -p ${CNI_CONFIG_PATH}
mkdir -p ${KUBE_ETC_PATH}
mkdir -p ${KUBE_ETC_PATH}/manifests
mkdir -p ${KUBE_ETC_PATH}/pki
mkdir -p ${KUBELET_VAR_PATH}
mkdir -p ${KUBELET_VAR_PATH}/pki
mkdir -p /run/kubelet

sudo tar -xvf /opt/cni/cni-plugins-linux.tgz -C ${CNI_BIN_PATH}/

# Generate configs
function generate::file() {
  local src=$1
  local dest=$2

  if test -f ${src} && ! test -f ${dest} ; then 
    envsubst < ${src} > ${dest}
  fi
}

KUBELET_CONFIG_SRC="${KUBE_OPT_PATH}/templates/config.yaml.tpl"
KUBELET_CONFIG_DEST="${KUBELET_VAR_PATH}/config.yaml"
generate::file ${KUBELET_CONFIG_SRC} ${KUBELET_CONFIG_DEST}

CA_CONFIG_SRC="${KUBE_OPT_PATH}/templates/ca-config.json.tpl"
CA_CONFIG_DEST="${KUBELET_VAR_PATH}/pki/ca-config.json"
CSR_FILE_SRC="${KUBE_OPT_PATH}/templates/kubelet-csr.json.tpl"
CSR_FILE_DEST="${KUBELET_VAR_PATH}/pki/csr.json"
FILE_NAME="kubelet-client-current.pem"
if test -f ${CSR_FILE_SRC} && ! test -f ${KUBELET_VAR_PATH}/pki/${FILE_NAME} ; then 
  generate::file ${CA_CONFIG_SRC} ${CA_CONFIG_DEST}
  generate::file ${CSR_FILE_SRC} ${CSR_FILE_DEST}

  ${DOCKER_EXEC} run --rm \
  -v ${KUBELET_VAR_PATH}/pki/:/tmp/pki/ \
  -v ${KUBE_ETC_PATH}/pki/:${KUBE_ETC_PATH}/pki/ \
  -e HOSTNAME=${HOSTNAME} \
  ${CFSSL_IMAGE} \
    /bin/sh -c "cfssl gencert -ca=${KUBE_ETC_PATH}/pki/ca.crt -ca-key=${KUBE_ETC_PATH}/pki/ca.key -hostname=${HOSTNAME} -config=/tmp/pki/ca-config.json -profile=kubernetes /tmp/pki/csr.json | cfssljson -bare /tmp/pki/kubelet-client"

  DATE=$(date +%Y-%m-%d)
  cat ${KUBELET_VAR_PATH}/pki/kubelet-client.pem > ${KUBELET_VAR_PATH}/pki/kubelet-client-${DATE}.pem
  cat ${KUBELET_VAR_PATH}/pki/kubelet-client-key.pem >> ${KUBELET_VAR_PATH}/pki/kubelet-client-${DATE}.pem

  ln -s ${KUBELET_VAR_PATH}/pki/kubelet-client-${DATE}.pem ${KUBELET_VAR_PATH}/pki/kubelet-client-current.pem

  rm -rf ${CSR_FILE_DEST} \
    ${CA_CONFIG_DEST} \
    ${KUBELET_VAR_PATH}/pki/kubelet-client.csr \
    ${KUBELET_VAR_PATH}/pki/kubelet-client.pem \
    ${KUBELET_VAR_PATH}/pki/kubelet-client-key.pem
fi

BOOTSTRAPPING_KUBECONFIG="${KUBE_ETC_PATH}/bootstrap-kubelet.conf"
if test -f ${BOOTSTRAPPING_KUBECONFIG} ; then 
  grep 'certificate-authority-data' ${BOOTSTRAPPING_KUBECONFIG} | awk '{print $2}' | base64 -d > ${KUBE_ETC_PATH}/pki/ca.crt
fi
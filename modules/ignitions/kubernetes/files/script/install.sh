#!/bin/bash
# Wrapper script for installing Kubernetes.

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

require_ev_all KUBELET_URL KUBECTL_URL CNI_PLUGIN_URL
require_ev_all KUBELET_CHECKSUM KUBECTL_CHECKSUM CNI_PLUGIN_CHECKSUM
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

# Copy binaries to host
function download::binary() {
    local url=$1
    local filename=$2
    local checksum=$3

    sudo curl -sL ${url} -o ${OPT_BIN_PATH}/${filename}
    echo "${checksum} ${OPT_BIN_PATH}/${filename}" | sha256sum -c 
    sudo chmod 500 ${OPT_BIN_PATH}/${filename}
    sudo chown root ${OPT_BIN_PATH}/${filename}
}

function download::tar() {
    local url=$1
    local filename=$2
    local checksum=$3
    local dir=$4

    sudo curl -sL ${url} -o /tmp/${filename}
    echo "${checksum} /tmp/${filename}" | sha256sum -c 
    sudo tar -xvf /tmp/${filename} -C ${dir}/
}

if ! test -f ${OPT_BIN_PATH}/kubelet ; then
  download::binary ${KUBELET_URL} kubelet ${KUBELET_CHECKSUM}
fi

if ! test -f ${OPT_BIN_PATH}/kubectl ; then
  download::binary ${KUBECTL_URL} kubectl ${KUBECTL_CHECKSUM}
fi

if ! test -f ${CNI_BIN_PATH}/host-local ; then
  download::tar ${CNI_PLUGIN_URL} cni-plugins-linux.tgz ${CNI_PLUGIN_CHECKSUM} ${CNI_BIN_PATH}
fi

# Generate configs
function generate::file() {
  local src=$1
  local dest=$2

  if test -f ${src} && ! test -f ${dest} ; then 
    envsubst < ${src} > ${dest}
  fi
}

APISERVER_YAML_SRC="${KUBE_OPT_PATH}/templates/kube-apiserver.yaml.tpl"
APISERVER_YAML_DEST="${KUBE_ETC_PATH}/manifests/kube-apiserver.yaml"
generate::file ${APISERVER_YAML_SRC} ${APISERVER_YAML_DEST}

KUBELET_CONFIG_SRC="${KUBE_OPT_PATH}/templates/config.yaml.tpl"
KUBELET_CONFIG_DEST="${KUBELET_VAR_PATH}/config.yaml"
generate::file ${KUBELET_CONFIG_SRC} ${KUBELET_CONFIG_DEST}

CA_CONFIG_SRC="${KUBE_OPT_PATH}/templates/ca-config.json.tpl"
CA_CONFIG_DEST="${KUBELET_VAR_PATH}/pki/ca-config.json"
CSR_FILE_SRC="${KUBE_OPT_PATH}/templates/kubelet-csr.json.tpl"
CSR_FILE_DEST="${KUBELET_VAR_PATH}/pki/csr.json"

DATE=$(date +%Y-%m-%d)
FILE_NAME="kubelet-client-current.pem"
if test -f ${CSR_FILE_SRC} && ! test -f ${KUBELET_VAR_PATH}/pki/${FILE_NAME} ; then 
  envsubst < ${CA_CONFIG_SRC} > ${CA_CONFIG_DEST}
  envsubst < ${CSR_FILE_SRC} > ${CSR_FILE_DEST}

  ${DOCKER_EXEC} run --rm \
  -v ${KUBELET_VAR_PATH}/pki/:/tmp/pki/ \
  -v ${KUBE_ETC_PATH}/pki/:${KUBE_ETC_PATH}/pki/ \
  -e HOSTNAME=${HOSTNAME} \
  ${CFSSL_IMAGE} \
    /bin/sh -c "cfssl gencert -ca=${KUBE_ETC_PATH}/pki/ca.crt -ca-key=${KUBE_ETC_PATH}/pki/ca.key -hostname=${HOSTNAME} -config=/tmp/pki/ca-config.json -profile=kubernetes /tmp/pki/csr.json | cfssljson -bare /tmp/pki/kubelet-client"

  cat ${KUBELET_VAR_PATH}/pki/kubelet-client.pem > ${KUBELET_VAR_PATH}/pki/kubelet-client-${DATE}.pem
  cat ${KUBELET_VAR_PATH}/pki/kubelet-client-key.pem >> ${KUBELET_VAR_PATH}/pki/kubelet-client-${DATE}.pem

  ln -s ${KUBELET_VAR_PATH}/pki/kubelet-client-${DATE}.pem ${KUBELET_VAR_PATH}/pki/kubelet-client-current.pem

  rm -rf ${CSR_FILE_DEST} \
    ${CA_CONFIG_DEST} \
    ${KUBELET_VAR_PATH}/pki/kubelet-client.csr \
    ${KUBELET_VAR_PATH}/pki/kubelet-client.pem \
    ${KUBELET_VAR_PATH}/pki/kubelet-client-key.pem
fi
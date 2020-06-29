# ETCD SELF DEFINE CONFIGURATION
ETCD_IMAGE_URL=${image_url}
ETCD_IMAGE_TAG=${image_tag}
CLIENT_PORT=${client_port}
PEER_PORT=${peer_port}
SCHEME=${scheme}
USER_ID=${user_id}

# ETCD OFFICIAL CONFIGURATION
ETCD_CERT_PATH=${certs_path}
ETCD_CERT_FILE=${certs_path}/server.crt
ETCD_KEY_FILE=${certs_path}/server.key
ETCD_PEER_CERT_FILE=${certs_path}/peer.crt
ETCD_PEER_KEY_FILE=${certs_path}/peer.key
ETCD_PEER_TRUSTED_CA_FILE=${certs_path}/ca.crt
ETCD_TRUSTED_CA_FILE=${certs_path}/ca.crt
ETCD_PEER_CLIENT_CERT_AUTH=true
ETCD_CLIENT_CERT_AUTH=true
ETCD_LISTEN_CLIENT_URLS=${scheme}://0.0.0.0:${client_port}
ETCD_LISTEN_PEER_URLS=${scheme}://0.0.0.0:${peer_port}
ETCD_DATA_DIR=${data_path}
ETCD_DISCOVERY_SRV=${discovery_service}
ETCD_INITIAL_CLUSTER_TOKEN=${cluster_name}
ETCD_LOGGER=zap
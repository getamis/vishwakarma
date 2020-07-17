apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - name: kube-apiserver
    image: ${image}
    command:
    - kube-apiserver
    - --secure-port=${secure_port}
    - --client-ca-file=${pki_path}/ca.crt
    - --kubelet-client-certificate=${pki_path}/apiserver-kubelet-client.crt
    - --kubelet-client-key=${pki_path}/apiserver-kubelet-client.key
    - --tls-cert-file=${pki_path}/apiserver.crt
    - --tls-private-key-file=${pki_path}/apiserver.key
    - --requestheader-client-ca-file=${pki_path}/front-proxy-ca.crt
    - --proxy-client-cert-file=${pki_path}/front-proxy-client.crt
    - --proxy-client-key-file=${pki_path}/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --service-account-key-file=${pki_path}/sa.pub
    - --etcd-servers=${etcd_endpoints}
    - --etcd-cafile=${etcd_pki_path}/ca.crt
    - --etcd-certfile=${pki_path}/apiserver-etcd-client.crt
    - --etcd-keyfile=${pki_path}/apiserver-etcd-client.key
%{ if service_cidr != "" ~}
    - --service-cluster-ip-range=${service_cidr}
%{ endif ~}
%{ if cloud_provider != "" ~}
    - --cloud-provider=${cloud_provider}
    ${cloud_config_flag}
%{ endif ~}
%{ for flag, value in extra_flags ~}
%{ if value != "" ~}
    - --${flag}=${value}
%{ endif ~}
%{ endfor ~}
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: ${secure_port}
        scheme: HTTPS
      initialDelaySeconds: 15
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 250m
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/ca-certificates
      name: etc-ca-certificates
      readOnly: true
    - mountPath: ${pki_path}
      name: k8s-certs
      readOnly: true
    - mountPath: ${config_path}
      name: k8s-configs
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
    - mountPath: ${log_path}
      name: k8s-logs
  hostNetwork: true
  priorityClassName: system-cluster-critical
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  - hostPath:
      path: ${pki_path}
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: ${config_path}
      type: DirectoryOrCreate
    name: k8s-configs
  - hostPath:
      path: ${log_path}
      type: DirectoryOrCreate
    name: k8s-logs
  - hostPath:
      path: /usr/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-share-ca-certificates
status: {}
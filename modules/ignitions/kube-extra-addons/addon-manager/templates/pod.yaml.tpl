apiVersion: v1
kind: Pod
metadata:
  name: kube-addon-manager
  namespace: kube-system
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ''
    seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
  labels:
    component: kube-addon-manager
spec:
  priorityClassName: system-cluster-critical
  hostNetwork: true
  containers:
  - name: kube-addon-manager
    image: ${image}
    command:
    - /bin/bash
    - -c
    - exec /opt/kube-addons.sh 1>>/var/log/kube-addon-manager.log 2>&1
    env:
    - name: KUBECTL_EXTRA_PRUNE_WHITELIST
      value: "${kubectl_extra_prune_whitelist}"
    resources:
      requests:
        cpu: 3m
        memory: 50Mi
    volumeMounts:
    - mountPath: /etc/kubernetes/addons
      name: addons
      readOnly: true
    - mountPath: /var/log
      name: varlog
  volumes:
  - hostPath:
      path: ${addons_dir_path}
    name: addons
  - hostPath:
      path: ${logs_dir_path}
    name: varlog
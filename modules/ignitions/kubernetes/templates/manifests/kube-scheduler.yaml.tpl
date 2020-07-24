apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-scheduler
    tier: control-plane
  name: kube-scheduler
  namespace: kube-system
spec:
  containers:
  - name: kube-scheduler
    image: ${image}
    command:
    - kube-scheduler
    - --bind-address=127.0.0.1
    - --authentication-kubeconfig=${kubeconfig}
    - --authorization-kubeconfig=${kubeconfig}
    - --kubeconfig=${kubeconfig}
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
        port: 10259
        scheme: HTTPS
      initialDelaySeconds: 15
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 100m
    volumeMounts:
    - mountPath: ${kubeconfig}
      name: kubeconfig
      readOnly: true
  hostNetwork: true
  priorityClassName: system-cluster-critical
  volumes:
  - hostPath:
      path: ${kubeconfig}
      type: FileOrCreate
    name: kubeconfig
status: {}
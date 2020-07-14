# clusters refers to the remote service.
clusters:
  - name: aws-iam-authenticator
    cluster:
      certificate-authority-data: ${ca}
      server: https://127.0.0.1:${server_port}/authenticate
# users refers to the API Server's webhook configuration
# (we don't need to authenticate the API server).
users:
  - name: apiserver
# kubeconfig files require a context. Provide one for the API Server.
current-context: webhook
contexts:
- name: webhook
  context:
    cluster: aws-iam-authenticator
    user: apiserver

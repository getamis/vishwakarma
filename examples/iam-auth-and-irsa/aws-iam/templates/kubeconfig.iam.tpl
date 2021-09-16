apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${cluster_ca}
    server: ${api_server_endpoint}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    namespace: default
    user: ${user}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${user}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - eks
      - get-token
      - --cluster-name
      - ${cluster_name}
      - --role-arn
      - ${k8s_admin_iam_role}
      command: aws
      env: null
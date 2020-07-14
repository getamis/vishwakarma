%{ if content != "" ~}
${content}
%{ else ~}
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${cluster_ca_certificate}
    server: https://${endpoint}
  name: ${cluster}
contexts:
- context:
    cluster: ${cluster}
    user: ${user}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${user}
  user:
%{ if token != "" ~}
    token: ${token} 
%{ else ~}
%{ if client_cert_data != "" && client_key_data != ""  ~}
    client-certificate-data: ${client_cert_data}
    client-key-data: ${client_key_data} 
%{ endif ~}
%{ if client_cert_path != "" && client_key_path != "" ~}
    client-certificate: ${client_cert_path}
    client-key: ${client_key_path} 
%{ endif ~}
%{ endif ~}
%{ endif ~}
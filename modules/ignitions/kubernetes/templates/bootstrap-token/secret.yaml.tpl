apiVersion: v1
kind: Secret
metadata:
  name: bootstrap-token-${id}
  namespace: kube-system
type: bootstrap.kubernetes.io/token
data:
  token-id: ${base64encode(id)}
  token-secret: ${base64encode(secret)}
  usage-bootstrap-authentication: dHJ1ZQ==
  usage-bootstrap-signing: dHJ1ZQ==
  auth-extra-groups: c3lzdGVtOmJvb3RzdHJhcHBlcnM6a3ViZWxldDpkZWZhdWx0LW5vZGUtdG9rZW4=
  description: VGhlIGRlZmF1bHQgYm9vdHN0cmFwIHRva2VuIGdlbmVyYXRlZCBieSAndGVycmFmb3JtJw==


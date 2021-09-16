apiVersion: iamauthenticator.k8s.aws/v1alpha1
kind: IAMIdentityMapping
metadata:
  name: ${user}
spec:
  arn: ${k8s_admin_iam_role}
  username: ${user}
  groups:
  - system:masters
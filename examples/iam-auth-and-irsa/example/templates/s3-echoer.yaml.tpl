apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-echoer
  annotations:
    k8s.amazonaws.com/role-arn: "${role_arn}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: s3-echoer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: s3-echoer
  template:
    metadata:
      labels:
        app: s3-echoer
    spec:
      serviceAccountName: s3-echoer
      containers:
      - name: ubuntu
        image: ubuntu:20.04
        command: ["/bin/bash"]
        args: ["-c", "
        apt-get update && apt-get install -y curl zip; 
        curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip;
        unzip awscliv2.zip;
        ./aws/install;
        rm -rf awscliv2.zip;
        while :; do sleep 3600; done"]
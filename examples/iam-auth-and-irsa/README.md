# IAM integrate with Kubernetes
This example demonstrates how to setup IAM Authenticator and IRSA(IAM roles for service accounts).

## Running this module manually

1. Sign up for [AWS](https://aws.amazon.com/).
2. Configure your AWS credentials using one of the [supported methods for AWS CLI
   tools](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), such as setting the
   `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. If you're using the `~/.aws/config` file for profiles then export `AWS_SDK_LOAD_CONFIG` as "True".
3. Install [Terraform v1.0.0+](https://www.terraform.io/) and make sure it's on your `PATH`.

4. Install Golang environment for IRSA preparation

5. Execute below commands to setup Kubernetes cluster:

```sh
# Go to k8s-cluster directory
$ cd k8s-cluster

# Initial for sync terraform module and install provider plugins
$ terraform init

# create the AWS resource for kubernetes cluster 
$ terraform apply
```

5. Login Bastion and Execute below commands to deploy IAM role and examples:

```sh
# Go to aws-iam directory, and type your oidc endpoint, ARN, and ignition bucket name.
$ terraform init
$ terraform apply

# export kubeconfig in this directory, and execute the following commands
$ export KUBECONFIG=.secret/kubeconfig
$ kubectl taint nodes --all node-role.kubernetes.io/master-
$ kubectl get pod
$ kubectl exec -ti s3-echoer-89ddf8b7f-82pfb aws s3 ls
```

6. When you're done, execute below command to destroy:

```sh
# Go to example directory
$ terraform destroy

# Go to k8s-cluster directory
$ terraform destroy -target=module.master
$ terraform destroy -target=module.irsa
$ terraform destroy -target=module.network
```
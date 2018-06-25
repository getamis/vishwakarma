# vishwakarma

Vishwakarma can be used to create a Kubernetes cluster in AWS by leveraging HashiCorp Terraform and CoreOS. Of course, I didn't develop it from scratch, I refer to [CoreOS Tectonic](https://github.com/coreos/tectonic-installer) and [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks), before starting to dive into the detail, let's experience it first

## Dependencies

- **Terraform**: All of the AWS resource will be create by Terraform, hence, you need to [**install it**](https://www.terraform.io/intro/getting-started/install.html) and confirm the [**permission setup**](https://www.terraform.io/docs/providers/aws/index.html) correctly, then Terraform have the permission to create AWS resource automatically

- **kubectl**: After AWS EKS cluster created completely, there is a Kubernetes ConfigMap aws-auth need to be created through kubectl, so need to [**install it**](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)

- **heptio-authenticator-aws**: AWS EKS access permission integrate with AWS IAM, in order to let AWS EKS know whether you have the right to access, heptio-authenticator-aws need to be [**installed**](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) in the client side


## Getting Started

Acquire Vishwakarma from github, and switch to the example folder

```
~$ git clone https://github.com/getamis/vishwakarma.git
~$ cd examples/eks_worker
```

Then execute Terraform command to create AWS resource

```
# initial for sync terraform module and install provider plugins

~$ terraform init

Initializing modules...
- module.network
- module.master
...
Terraform has been successfully initialized!

# check how many aws resource will be created

~$ terraform plan

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
...
Plan: 74 to add, 0 to change, 0 to destroy.

# start to create Kubernetes cluster

~$ terraform apply

data.ignition_systemd_unit.locksmithd: Refreshing state...
data.template_file.aws_auth_cm: Refreshing state...
data.template_file.max_user_watches: Refreshing state...
...
Apply complete! Resources: 74 added, 0 changed, 0 destroyed.
```

Verify the Kubernetes cluster is up! (Still keep in the same folder)

```
# setup kubeconfig for kubectl to access eks

~$ export KUBECONFIG=.terraform/kubeconfig

# check whether there is 4 worker register successfully, it will takes several
minutes...

~$ kubectl get node

NAME                          STATUS    ROLES     AGE       VERSION
ip-10-0-48-247.ec2.internal   Ready     node      2m        v1.10.3+coreos.0
ip-10-0-66-127.ec2.internal   Ready     node      2m        v1.10.3+coreos.0
ip-10-0-71-121.ec2.internal   Ready     node      22s       v1.10.3+coreos.0
ip-10-0-86-182.ec2.internal   Ready     node      2m        v1.10.3+coreos.0
```

## Modules
Vishwakarma include 4 major module:

### aws/network
Create one AWS VPC including private and public subnet, and one ec2 instance called bastion hosts in public subnet, hence, one can access the resource hosting in the private subnet.

- Refer [**Here**](VARIABLES.md#aws/network) for the detail variable inputs

### aws/eks/master
This module creates the AWS EKS cluster, I think this is the most simple part here, but it takes about 8~10 minutes

- Refer [**Here**](VARIABLES.md#eks/master) for the detail variable inputs


### aws/eks/worker-asg
Create a AWS auto-scaling group with CoreOS container linux and leverage ignition to provision and register to EKS cluster automatically

- Refer [**Here**](VARIABLES.md#eks/worker-asg) for the detail variable inputs


### aws/eks/worker-spot
Module worker-spot almost do the same thing like worker-asg, but it uses spot fleet to launch worker node group, that means comparing to worker-asg, the cost is only half

- Refer [**Here**](VARIABLES.md#eks/worker-spot) for the detail variable inputs

## Contributing

There are several ways to contribute to this project:

1. **Find bug**: create an issue in our Github issue tracker.
2. **Fix a bug**: check our issue tracker, leave comments and send a pull request to us to fix a bug.
3. **Make new feature**: leave your idea in the issue tracker and discuss with us then send a pull request!


## Change log

The [changelog](CHANGELOG.md) captures all important release notes.


## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details

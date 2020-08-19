[![CircleCI](https://circleci.com/gh/getamis/vishwakarma/tree/master.svg?style=svg)](https://circleci.com/gh/getamis/vishwakarma/tree/master) [![GitHub license](https://img.shields.io/github/license/getamis/vishwakarma)](https://github.com/getamis/vishwakarma/blob/master/LICENSE)
# Vishwakarma
Vishwakarma is a Kubernetes distro, it can be used to create a Kubernetes/etcd cluster on opinionated Cloud Platform by leveraging HashiCorp Terraform  and Container OS(CoreOS Container Linux, Flatcar Container Linux and Fedora CoreOS).

![Alt text](https://cdn-images-1.medium.com/max/800/1*ocPrvGrCORzJiF3rK3GG_g.png)

## Features

* Kubernetes v1.18.0+.
* Supported [AWS VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s), or [flannel](https://github.com/coreos/flannel) networking.
* RBAC-enabled, Audit log, and etcd data encryption.
* etcd v3.4.0+.
* On-cluster etcd with TLS. 

## What’s Going On?
You have completed one Kubernetes cluster the same as below picture, and let me briefly explain how Vishwakarma achieves it.

![Alt text](https://cdn-images-1.medium.com/max/800/1*tvAY88CzHhxo4lBB6OUSyA.png)

## Modules
Vishwakarma includes serveral major modules:

### aws/network
Create one AWS VPC including private and public subnet, and one ec2 instance called bastion hosts in public subnet, hence, one can access the resource hosting in the private subnet, refer [**aws/network**](Documentation/variables/aws/network.md) for the detail variable inputs.

### aws/elastikube
This module creates the Kubernetes control plane, Terraform is responsible for the complicated Kubernetes compoments, and it takes about 10~15 minutes to complete, refer [**aws/elastikube**](Documentation/variables/aws/elastikube.md) for the detail variable inputs.

### aws/kube-worker
Create a AWS auto-scaling group with CoreOS container linux and leverage ignition to provision and register to ElastiKube automatically.

Due to using AWS launch template, hence, it's up to user to choose spot or on demand instance type by changing the variable, refer [**aws/kube-worker**](Documentation/variables/aws/kube-worker.md) for the detail variable inputs.

## Contributing
There are several ways to contribute to this project:

1. **Find bug**: create an issue in our Github issue tracker.
2. **Fix a bug**: check our issue tracker, leave comments and send a pull request to us to fix a bug.
3. **Make new feature**: leave your idea in the issue tracker and discuss with us then send a pull request!

## Changelog
The [Changelog](CHANGELOG.md) captures all important release notes.

## License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

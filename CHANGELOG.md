# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).


<a name="v1.27.4.0"></a>
## [v1.27.4.0] - 2023-09-19

- upgrade k8s to 1.27.4 and cilium to v1.14.2 ([#169](https://github.com/getamis/vishwakarma/issues/169))


<a name="v1.27.2.2"></a>
## [v1.27.2.2] - 2023-08-18

- Support aws cloud controller manager ([#168](https://github.com/getamis/vishwakarma/issues/168))
- update cilium version to v1.13.4 ([#167](https://github.com/getamis/vishwakarma/issues/167))


<a name="v1.27.2.1"></a>
## [v1.27.2.1] - 2023-06-26

- add ecr-cred-provider ([#165](https://github.com/getamis/vishwakarma/issues/165))


<a name="v1.27.2.0"></a>
## [v1.27.2.0] - 2023-06-14

- Upgrade k8s version to 1.27.2 ([#162](https://github.com/getamis/vishwakarma/issues/162))


<a name="v1.23.10.5"></a>
## [v1.23.10.5] - 2023-01-31

- oidc server name output incorrect ([#161](https://github.com/getamis/vishwakarma/issues/161))
- region condition error ([#160](https://github.com/getamis/vishwakarma/issues/160))
- bash syntax error ([#159](https://github.com/getamis/vishwakarma/issues/159))
- module will fail when create cluster at us-east-1 region ([#158](https://github.com/getamis/vishwakarma/issues/158))


<a name="v1.23.10.4"></a>
## [v1.23.10.4] - 2022-12-07

- etcd terraform module improvement ([#157](https://github.com/getamis/vishwakarma/issues/157))


<a name="v1.23.10.3"></a>
## [v1.23.10.3] - 2022-09-29

- Support Cilium CNI (VXLAN) and kube-proxy replacement  ([#153](https://github.com/getamis/vishwakarma/issues/153))
- change kubernetes module version
- upgrade module to make prometheus stack workable
- change makefile
- change local source ref to github ref
- fmt
- upgrade terraform to 1.2.0
- upgrade to 1.23.10
- Add variable to support extra aws resource tag for asg ([#150](https://github.com/getamis/vishwakarma/issues/150))
- change flatcar ami to 3227.2.1
- change version ref
- refer to github url
- upgrade provider to 2.1.2
- update version


<a name="v1.19.16.3"></a>
## [v1.19.16.3] - 2022-09-29

- support etcd-metrics-proxy ([#156](https://github.com/getamis/vishwakarma/issues/156))


<a name="v1.23.10.2"></a>
## [v1.23.10.2] - 2022-09-27

- change kubernetes module version


<a name="v1.23.10.1"></a>
## [v1.23.10.1] - 2022-08-31

- upgrade module to make prometheus stack workable


<a name="v1.23.10.0"></a>
## [v1.23.10.0] - 2022-08-26

- change makefile
- change local source ref to github ref
- fmt
- upgrade terraform to 1.2.0
- upgrade to 1.23.10


<a name="v1.19.16.2"></a>
## [v1.19.16.2] - 2022-08-25

- Add variable to support extra aws resource tag for asg ([#150](https://github.com/getamis/vishwakarma/issues/150))


<a name="v1.19.16.1"></a>
## [v1.19.16.1] - 2022-08-11

- change flatcar ami to 3227.2.1
- change version ref
- refer to github url
- upgrade provider to 2.1.2
- update version


<a name="v1.19.16.0"></a>
## [v1.19.16.0] - 2022-06-01



<a name="v1.3.1"></a>
## [v1.3.1] - 2022-05-24

- add new variables to override asg and warm pool max capacity ([#147](https://github.com/getamis/vishwakarma/issues/147))


<a name="v1.3.0"></a>
## [v1.3.0] - 2022-05-20

- support node graceful shutdown and ec2 auto scaling warm pool ([#146](https://github.com/getamis/vishwakarma/issues/146))


<a name="v1.2.20"></a>
## [v1.2.20] - 2022-05-08



<a name="v1.2.19"></a>
## [v1.2.19] - 2022-04-25
FEATURES:
- add annotate_pod_ip and components_resource variables ([#143](https://github.com/getamis/vishwakarma/issues/143))


<a name="v1.2.18"></a>
## [v1.2.18] - 2022-04-10



<a name="v1.2.17"></a>
## [v1.2.17] - 2022-03-17



<a name="v1.2.16"></a>
## [v1.2.16] - 2022-02-09
BUG FIXES:
- only primary sg can be tagged as owned by the cluster


<a name="v1.2.15"></a>
## [v1.2.15] - 2022-01-21
FEATURES:
- add enable_extra_sg var to create sg for worker group ([#139](https://github.com/getamis/vishwakarma/issues/139))


<a name="v1.2.14"></a>
## [v1.2.14] - 2022-01-14
FEATURES:
- upgarde terraform-ignition-kubernetes to v1.4.10 ([#138](https://github.com/getamis/vishwakarma/issues/138))


<a name="v1.2.13"></a>
## [v1.2.13] - 2021-12-15
BUG FIXES:
- create duplicate worker role when var.role_name is set ([#137](https://github.com/getamis/vishwakarma/issues/137))


<a name="v1.2.12"></a>
## [v1.2.12] - 2021-11-10

- getamis/vishwakarma


<a name="v1.2.11"></a>
## [v1.2.11] - 2021-10-21

- getamis/vishwakarma


<a name="v1.2.10"></a>
## [v1.2.10] - 2021-10-15

- support eni prefix ([#134](https://github.com/getamis/vishwakarma/issues/134))


<a name="v1.2.9"></a>
## [v1.2.9] - 2021-09-28

- Fix ssh related sg cidr block ([#133](https://github.com/getamis/vishwakarma/issues/133))


<a name="v1.2.8"></a>
## [v1.2.8] - 2021-09-27

- Add etcd rolling update document ([#132](https://github.com/getamis/vishwakarma/issues/132))


<a name="v1.2.7"></a>
## [v1.2.7] - 2021-09-25

- ship kubelet log to file ([#131](https://github.com/getamis/vishwakarma/issues/131))


<a name="v1.2.6"></a>
## [v1.2.6] - 2021-09-22

- Upgrade component version & fix kubelet flag value error ([#130](https://github.com/getamis/vishwakarma/issues/130))


<a name="v1.2.5"></a>
## [v1.2.5] - 2021-09-22
FEATURES:
- upgrade terraform-ignition-kubernetes to v1.4.2 ([#125](https://github.com/getamis/vishwakarma/issues/125))


<a name="v1.2.4"></a>
## [v1.2.4] - 2021-08-06

- getamis/vishwakarma


<a name="v1.2.3"></a>
## [v1.2.3] - 2021-07-05

- getamis/vishwakarma


<a name="v1.2.2"></a>
## [v1.2.2] - 2021-06-26
FEATURES:
- set spot_max_price default to "" instead of null

BUG FIXES:
- spot_max_price attribute


<a name="v1.2.1"></a>
## [v1.2.1] - 2021-06-18

- getamis/vishwakarma


<a name="v1.2.0"></a>
## [v1.2.0] - 2021-04-22



<a name="v1.1.2"></a>
## [v1.1.2] - 2021-04-14
FEATURES:
- upgrade aws-pod-identity-webhook module to v1.2.0
- modify irsa ignition module variable
- output kubernetes_ca_cert for irsa setting
- set webhook_ca_bundle variable, and apply to ignition for mutatingwebhookconfigurations

BUG FIXES:
- irsa example
- upgrade aws-pod-identity-webhook to fix issues with k8s v1.19


<a name="v1.1.1"></a>
## [v1.1.1] - 2021-03-26

- add output for generated variables


<a name="v1.1.0"></a>
## [v1.1.0] - 2021-03-24
FEATURES:
- add iops and throughput attributes to support gp3,io1,io2 on worker nodes ([#112](https://github.com/getamis/vishwakarma/issues/112))
- set Name tag only by module `name` variable on aws_autoscaling_group of kube-master
- read the irsa keys.json only when we need it
- get oidc keys by file() to avoid different with s3 object every time
- add jq command on README Requirements

BUG FIXES:
- fix duplicate Name tag on aws_autoscaling_group of kube-worker
- give default throughput value 125 for any type of ebs
- the irsa thumbprint_list should be lower case

REFACTORS:
- use local variables to help condition
- remove unused default attributes for kube-master ebs volume


<a name="v1.0.5"></a>
## [v1.0.5] - 2020-12-08
FEATURES:
- unify binary key name


<a name="v1.0.4"></a>
## [v1.0.4] - 2020-12-07



<a name="v1.0.3"></a>
## [v1.0.3] - 2020-11-23



<a name="v1.0.2"></a>
## [v1.0.2] - 2020-11-19
REFACTORS:
- refactory IAM role for bastion, etcd, master and worker node ([#99](https://github.com/getamis/vishwakarma/issues/99))


<a name="v1.0.1"></a>
## [v1.0.1] - 2020-10-28
FEATURES:
- add controller primary for null_resource ([#96](https://github.com/getamis/vishwakarma/issues/96))


<a name="v1.0.0"></a>
## [v1.0.0] - 2020-10-23
BUG FIXES:
- lock terraform required version ([#94](https://github.com/getamis/vishwakarma/issues/94))
- rename CHANGELOG.pre-v0.2.0.md to v0.1.0 ([#84](https://github.com/getamis/vishwakarma/issues/84))

FEATURES:
- move ignitions modules to new repo ([#92](https://github.com/getamis/vishwakarma/issues/92))
- add new var for setting Kubernetes version ([#91](https://github.com/getamis/vishwakarma/issues/91))
- update os ami module and add version var ([#90](https://github.com/getamis/vishwakarma/issues/90))
- remove CoreOS Container Linux ([#89](https://github.com/getamis/vishwakarma/issues/89))
- add changelog generation script ([#83](https://github.com/getamis/vishwakarma/issues/83))

REFACTORS:
- refactor aws iam auth and irsa module ([#88](https://github.com/getamis/vishwakarma/issues/88))

ENHANCEMENTS:
- update etcd and kubernetes ignition source ([#87](https://github.com/getamis/vishwakarma/issues/87))
- update README.md ([#85](https://github.com/getamis/vishwakarma/issues/85))


[Unreleased]: https://github.com/getamis/vishwakarma/compare/v1.27.4.0...HEAD
[v1.27.4.0]: https://github.com/getamis/vishwakarma/compare/v1.27.2.2...v1.27.4.0
[v1.27.2.2]: https://github.com/getamis/vishwakarma/compare/v1.27.2.1...v1.27.2.2
[v1.27.2.1]: https://github.com/getamis/vishwakarma/compare/v1.27.2.0...v1.27.2.1
[v1.27.2.0]: https://github.com/getamis/vishwakarma/compare/v1.23.10.5...v1.27.2.0
[v1.23.10.5]: https://github.com/getamis/vishwakarma/compare/v1.23.10.4...v1.23.10.5
[v1.23.10.4]: https://github.com/getamis/vishwakarma/compare/v1.23.10.3...v1.23.10.4
[v1.23.10.3]: https://github.com/getamis/vishwakarma/compare/v1.19.16.3...v1.23.10.3
[v1.19.16.3]: https://github.com/getamis/vishwakarma/compare/v1.23.10.2...v1.19.16.3
[v1.23.10.2]: https://github.com/getamis/vishwakarma/compare/v1.23.10.1...v1.23.10.2
[v1.23.10.1]: https://github.com/getamis/vishwakarma/compare/v1.23.10.0...v1.23.10.1
[v1.23.10.0]: https://github.com/getamis/vishwakarma/compare/v1.19.16.2...v1.23.10.0
[v1.19.16.2]: https://github.com/getamis/vishwakarma/compare/v1.19.16.1...v1.19.16.2
[v1.19.16.1]: https://github.com/getamis/vishwakarma/compare/v1.19.16.0...v1.19.16.1
[v1.19.16.0]: https://github.com/getamis/vishwakarma/compare/v1.3.1...v1.19.16.0
[v1.3.1]: https://github.com/getamis/vishwakarma/compare/v1.3.0...v1.3.1
[v1.3.0]: https://github.com/getamis/vishwakarma/compare/v1.2.20...v1.3.0
[v1.2.20]: https://github.com/getamis/vishwakarma/compare/v1.2.19...v1.2.20
[v1.2.19]: https://github.com/getamis/vishwakarma/compare/v1.2.18...v1.2.19
[v1.2.18]: https://github.com/getamis/vishwakarma/compare/v1.2.17...v1.2.18
[v1.2.17]: https://github.com/getamis/vishwakarma/compare/v1.2.16...v1.2.17
[v1.2.16]: https://github.com/getamis/vishwakarma/compare/v1.2.15...v1.2.16
[v1.2.15]: https://github.com/getamis/vishwakarma/compare/v1.2.14...v1.2.15
[v1.2.14]: https://github.com/getamis/vishwakarma/compare/v1.2.13...v1.2.14
[v1.2.13]: https://github.com/getamis/vishwakarma/compare/v1.2.12...v1.2.13
[v1.2.12]: https://github.com/getamis/vishwakarma/compare/v1.2.11...v1.2.12
[v1.2.11]: https://github.com/getamis/vishwakarma/compare/v1.2.10...v1.2.11
[v1.2.10]: https://github.com/getamis/vishwakarma/compare/v1.2.9...v1.2.10
[v1.2.9]: https://github.com/getamis/vishwakarma/compare/v1.2.8...v1.2.9
[v1.2.8]: https://github.com/getamis/vishwakarma/compare/v1.2.7...v1.2.8
[v1.2.7]: https://github.com/getamis/vishwakarma/compare/v1.2.6...v1.2.7
[v1.2.6]: https://github.com/getamis/vishwakarma/compare/v1.2.5...v1.2.6
[v1.2.5]: https://github.com/getamis/vishwakarma/compare/v1.2.4...v1.2.5
[v1.2.4]: https://github.com/getamis/vishwakarma/compare/v1.2.3...v1.2.4
[v1.2.3]: https://github.com/getamis/vishwakarma/compare/v1.2.2...v1.2.3
[v1.2.2]: https://github.com/getamis/vishwakarma/compare/v1.2.1...v1.2.2
[v1.2.1]: https://github.com/getamis/vishwakarma/compare/v1.2.0...v1.2.1
[v1.2.0]: https://github.com/getamis/vishwakarma/compare/v1.1.2...v1.2.0
[v1.1.2]: https://github.com/getamis/vishwakarma/compare/v1.1.1...v1.1.2
[v1.1.1]: https://github.com/getamis/vishwakarma/compare/v1.1.0...v1.1.1
[v1.1.0]: https://github.com/getamis/vishwakarma/compare/v1.0.5...v1.1.0
[v1.0.5]: https://github.com/getamis/vishwakarma/compare/v1.0.4...v1.0.5
[v1.0.4]: https://github.com/getamis/vishwakarma/compare/v1.0.3...v1.0.4
[v1.0.3]: https://github.com/getamis/vishwakarma/compare/v1.0.2...v1.0.3
[v1.0.2]: https://github.com/getamis/vishwakarma/compare/v1.0.1...v1.0.2
[v1.0.1]: https://github.com/getamis/vishwakarma/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/getamis/vishwakarma/compare/v0.1.0...v1.0.0

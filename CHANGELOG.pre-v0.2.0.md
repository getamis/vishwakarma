# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).


<a name="v0.1.0"></a>
## [v0.1.0] - 2020-08-04

- feat: move etcd and Kubernetes ignition to new repos ([#82](https://github.com/getamis/vishwakarma/issues/82))
- Merge pull request [#81](https://github.com/getamis/vishwakarma/issues/81) from kairen/fix-from-kube-hunter
- Merge pull request [#80](https://github.com/getamis/vishwakarma/issues/80) from kairen/fix-kubelet
- Merge pull request [#79](https://github.com/getamis/vishwakarma/issues/79) from kairen/fix-examples
- Merge pull request [#77](https://github.com/getamis/vishwakarma/issues/77) from kairen/add-extra-addons
- Merge pull request [#76](https://github.com/getamis/vishwakarma/issues/76) from kairen/add-flatcar-linux
- Merge pull request [#78](https://github.com/getamis/vishwakarma/issues/78) from kairen/add-max-user-watches
- Merge pull request [#74](https://github.com/getamis/vishwakarma/issues/74) from kairen/kyle/refactor-kubernetes
- Add support AWS IRSA and new AWS IAM authenticator ([#71](https://github.com/getamis/vishwakarma/issues/71))
- Update testing and remove unnecessary files ([#69](https://github.com/getamis/vishwakarma/issues/69))
- Add latest AMI module ([#68](https://github.com/getamis/vishwakarma/issues/68))
- export etcd role ([#67](https://github.com/getamis/vishwakarma/issues/67))
- add /opt/bin into ectd & kubelet service ([#66](https://github.com/getamis/vishwakarma/issues/66))
- extract container related variable for top level module ([#64](https://github.com/getamis/vishwakarma/issues/64))
- Update changelog for v0.0.16 ([#63](https://github.com/getamis/vishwakarma/issues/63))
- Bump k8s version to v1.15.10 as default ([#62](https://github.com/getamis/vishwakarma/issues/62))
- Run kubelet on host directly ([#60](https://github.com/getamis/vishwakarma/issues/60))
- Use docker to replace rkt for running etcd ([#59](https://github.com/getamis/vishwakarma/issues/59))
- Limit max pods while network is amazon-vpc ([#58](https://github.com/getamis/vishwakarma/issues/58))
- Remove EKS modules and examples ([#57](https://github.com/getamis/vishwakarma/issues/57))
- Add new CNI support for Amazon VPC ([#56](https://github.com/getamis/vishwakarma/issues/56))
- Output master's default role name ([#54](https://github.com/getamis/vishwakarma/issues/54))
- addon/coredns: make sure that replicas is match master count ([#53](https://github.com/getamis/vishwakarma/issues/53))
- eks: add support for fargate ([#51](https://github.com/getamis/vishwakarma/issues/51))
- Bump Kubernetes version to v1.15 as default ([#49](https://github.com/getamis/vishwakarma/issues/49))
- Restructure addon folder ([#48](https://github.com/getamis/vishwakarma/issues/48))
- test: make sure that tests run in different region ([#47](https://github.com/getamis/vishwakarma/issues/47))
- fix packets drop issue ([#45](https://github.com/getamis/vishwakarma/issues/45))
- Fix EKS test ([#46](https://github.com/getamis/vishwakarma/issues/46))
- Bump Kubernetes to v1.14.10 ([#44](https://github.com/getamis/vishwakarma/issues/44))
- Fix tests and move TravisCI to CircleCI ([#43](https://github.com/getamis/vishwakarma/issues/43))
- Fix terraform validate and check-fmt ([#42](https://github.com/getamis/vishwakarma/issues/42))
- Update markdown format ([#41](https://github.com/getamis/vishwakarma/issues/41))
- Merge pull request [#40](https://github.com/getamis/vishwakarma/issues/40) from kairen/add-ci
- Merge pull request [#39](https://github.com/getamis/vishwakarma/issues/39) from kairen/fix-interpolation-only
- Bump Kubernetes to v1.14.9 ([#38](https://github.com/getamis/vishwakarma/issues/38))
- Merge pull request [#37](https://github.com/getamis/vishwakarma/issues/37) from kairen/update-provider
- Merge pull request [#36](https://github.com/getamis/vishwakarma/issues/36) from kairen/remove-quotes
- Merge pull request [#33](https://github.com/getamis/vishwakarma/issues/33) from getamis/feature/v1.0.0
- Merge pull request [#35](https://github.com/getamis/vishwakarma/issues/35) from kairen/bump-k8s-version
- Merge pull request [#34](https://github.com/getamis/vishwakarma/issues/34) from kairen/add-coredns-affinity
- Merge pull request [#29](https://github.com/getamis/vishwakarma/issues/29) from getamis/feature/v0.0.15
- Merge pull request [#28](https://github.com/getamis/vishwakarma/issues/28) from getamis/feature/spot_master


<a name="v0.0.13-3426987"></a>
## [v0.0.13-3426987] - 2020-01-20

- Output master's default role name


<a name="v0.0.13-f56d0ff"></a>
## [v0.0.13-f56d0ff] - 2019-11-25

- Bump Kubernetes version to 1.13.12 as default
- modules/kube-addon-dns: use affinity to replace nodeSelector


<a name="v0.0.16"></a>
## [v0.0.16] - 2019-11-15

- Merge pull request [#35](https://github.com/getamis/vishwakarma/issues/35) from kairen/bump-k8s-version
- Bump Kubernetes version to 1.13.12 as default
- Merge pull request [#34](https://github.com/getamis/vishwakarma/issues/34) from kairen/add-coredns-affinity
- modules/kube-addon-dns: use affinity to replace nodeSelector


<a name="v0.0.15"></a>
## [v0.0.15] - 2019-04-03

- update the document and module output description
- Merge pull request [#29](https://github.com/getamis/vishwakarma/issues/29) from getamis/feature/v0.0.15
- eks worker group replace coreos with official ami, add test for eks cluster
- upgrade module eks


<a name="v0.0.14"></a>
## [v0.0.14] - 2019-03-28

- modify change log for verion 0.0.12~14
- Merge pull request [#28](https://github.com/getamis/vishwakarma/issues/28) from getamis/feature/spot_master
- change for the review
- fix from code review
- fix test bug, add document
- add test for elastikube cluster by terratest
- change the folder for terratest


<a name="v0.0.13"></a>
## [v0.0.13] - 2019-03-22

- Merge pull request [#27](https://github.com/getamis/vishwakarma/issues/27) from TaopaiC/add-ssh-cidr-for-elastikube-worker
- Merge pull request [#25](https://github.com/getamis/vishwakarma/issues/25) from TaopaiC/rename-version-variable
- add a list of CIDR networks to allow ssh access to worker
- rename version variable to kubernetes_version


<a name="v0.0.12"></a>
## [v0.0.12] - 2019-02-26

- Merge pull request [#24](https://github.com/getamis/vishwakarma/issues/24) from getamis/feature/v0.0.12
- upgrade aws provider version, add s3 block block feature
- modify CHANGELOG.md


<a name="v0.0.11"></a>
## [v0.0.11] - 2018-12-18

- Merge pull request [#23](https://github.com/getamis/vishwakarma/issues/23) from getamis/v0.0.11
- upgrade to v1.13.1, minor refactory
- adopt launch template and mix instance policy
- k8s upgrade to 1.13.0, coredns replace kube-dns, support auditing feature
- add ignition kubernetes audit


<a name="v0.0.10"></a>
## [v0.0.10] - 2018-09-19

- Merge pull request [#19](https://github.com/getamis/vishwakarma/issues/19) from owensengoku/rename-for-workshop
- Merge pull request [#20](https://github.com/getamis/vishwakarma/issues/20) from getamis/heptio
- Merge pull request [#18](https://github.com/getamis/vishwakarma/issues/18) from bailantaotao/support-aws-iam-authenticator-for-elastickube
- add new kubeconfig for example aws-iam-authenticator
- rename .tf for more easy understanding
- examples: add aws-iam-authenticator
- aws: support auth_webhook_path variable
- ignitions: support aws-iam-authenticator
- ignitions/kube-control-plane: support authentication webhook config


<a name="v0.0.9"></a>
## [v0.0.9] - 2018-08-22

- update CHANGELOG.md
- Merge pull request [#17](https://github.com/getamis/vishwakarma/issues/17) from getamis/feature/ignition_example
- add kubelet_flag_extra_flags for each module
- modify mater seciruty group
- add necessary ignition, remove optional ignition
- Merge pull request [#16](https://github.com/getamis/vishwakarma/issues/16) from alanchchen/refactor/ignitions
- update document README.md and CHANGELOG.md
- Adjust master ELB health check method
- Fix some bugs in several ignition modules
- Ignition modules refactoring


<a name="v0.0.8"></a>
## [v0.0.8] - 2018-08-08

- Merge pull request [#14](https://github.com/getamis/vishwakarma/issues/14) from alanchchen/feature/iam-roles-refactoring
- IAM roles refactoring


<a name="v0.0.7"></a>
## [v0.0.7] - 2018-08-02

- Merge pull request [#15](https://github.com/getamis/vishwakarma/issues/15) from getamis/bug/upate_lastest_ca
- typo and ignition parameter input error
- add description for worker sg rule
- add flannel port for worker sg
- always update local ca
- Merge pull request [#13](https://github.com/getamis/vishwakarma/issues/13) from alanchchen/feature/move-out-ignitions
- Move the ignitions directory out


<a name="v0.0.6"></a>
## [v0.0.6] - 2018-08-01

- Merge pull request [#11](https://github.com/getamis/vishwakarma/issues/11) from getamis/bug_fix/aws_iam_role_paramater_changed
- remove import data aws_iam_role, due to use role_name directly
- remove customized role for etcd
- link policy and role only when role name is empty
- modify role arn to name
- Merge pull request [#10](https://github.com/getamis/vishwakarma/issues/10) from getamis/feature/extra_sg_master
- pass sg id into master module
- add security for master to access ectd
- let user add customized sg to api server lb


<a name="v0.0.5"></a>
## [v0.0.5] - 2018-07-31

- Merge pull request [#9](https://github.com/getamis/vishwakarma/issues/9) from getamis/feature/spot_instance
- add spot worker type
- let user can choose coreos update reboot strategy


<a name="v0.0.4"></a>
## [v0.0.4] - 2018-07-28

- Merge pull request [#8](https://github.com/getamis/vishwakarma/issues/8) from alanchchen/feature/elastikube
- Enhance the security of elastikube
- Support extra ignition files and systemd units in elastikube and support load balancers in worker module
- Add an example for ElastiKube cluster
- Add example worker module
- Add ElastiKube
- Add example for self-signed etcd certificates
- Add tls-related modules
- Add Kubernetes master module
- Add self-hosted etcd module
- Add ignition modules
- Add private zone support to network module


<a name="v0.0.3"></a>
## [v0.0.3] - 2018-07-06

- fix wrong photo
- update README.md
- Merge pull request [#6](https://github.com/getamis/vishwakarma/issues/6) from getamis/issue/lack_spot_fleet_role
- add spot fleet request role to cluster module to avoid terraform issue
- Merge pull request [#5](https://github.com/getamis/vishwakarma/issues/5) from getamis/issue/ssh_key
- rename key pair variable name, and modify README.md
- change default region
- let user input ec2 ssh key pair name manually
- Merge pull request [#4](https://github.com/getamis/vishwakarma/issues/4) from getamis/bug_fix/spot_fleet_role
- use
- modify REAEME.md
- modify README.md
- Merge pull request [#3](https://github.com/getamis/vishwakarma/issues/3) from getamis/v0.0.3
- complete the document
- add worker node example
- complete the eks worker node module
- refactory network, eks cluster, and adding aws-auth for eks


<a name="v0.0.2"></a>
## [v0.0.2] - 2018-06-22

- Merge pull request [#2](https://github.com/getamis/vishwakarma/issues/2) from getamis/v0.0.2
- complete the eks cluster


<a name="v0.0.1"></a>
## v0.0.1 - 2018-06-17

- Merge pull request [#1](https://github.com/getamis/vishwakarma/issues/1) from getamis/v0.0.1
- add bastion for user to access service within private network
- add basic vpc setup into network
- initial


[Unreleased]: https://github.com/getamis/vishwakarma/compare/v0.1.0...HEAD
[v0.1.0]: https://github.com/getamis/vishwakarma/compare/v0.0.13-3426987...v0.1.0
[v0.0.13-3426987]: https://github.com/getamis/vishwakarma/compare/v0.0.13-f56d0ff...v0.0.13-3426987
[v0.0.13-f56d0ff]: https://github.com/getamis/vishwakarma/compare/v0.0.16...v0.0.13-f56d0ff
[v0.0.16]: https://github.com/getamis/vishwakarma/compare/v0.0.15...v0.0.16
[v0.0.15]: https://github.com/getamis/vishwakarma/compare/v0.0.14...v0.0.15
[v0.0.14]: https://github.com/getamis/vishwakarma/compare/v0.0.13...v0.0.14
[v0.0.13]: https://github.com/getamis/vishwakarma/compare/v0.0.12...v0.0.13
[v0.0.12]: https://github.com/getamis/vishwakarma/compare/v0.0.11...v0.0.12
[v0.0.11]: https://github.com/getamis/vishwakarma/compare/v0.0.10...v0.0.11
[v0.0.10]: https://github.com/getamis/vishwakarma/compare/v0.0.9...v0.0.10
[v0.0.9]: https://github.com/getamis/vishwakarma/compare/v0.0.8...v0.0.9
[v0.0.8]: https://github.com/getamis/vishwakarma/compare/v0.0.7...v0.0.8
[v0.0.7]: https://github.com/getamis/vishwakarma/compare/v0.0.6...v0.0.7
[v0.0.6]: https://github.com/getamis/vishwakarma/compare/v0.0.5...v0.0.6
[v0.0.5]: https://github.com/getamis/vishwakarma/compare/v0.0.4...v0.0.5
[v0.0.4]: https://github.com/getamis/vishwakarma/compare/v0.0.3...v0.0.4
[v0.0.3]: https://github.com/getamis/vishwakarma/compare/v0.0.2...v0.0.3
[v0.0.2]: https://github.com/getamis/vishwakarma/compare/v0.0.1...v0.0.2

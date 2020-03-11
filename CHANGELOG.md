# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## [[v0.0.16](https://github.com/getamis/vishwakarma/compare/v0.0.16...v0.0.15)] - 2020-01-20]

### Added

- Add pod affinity for CoreDNS.

### Changed

- Bump Kubernetes version to v1.13.12.

## [[v0.0.15](https://github.com/getamis/vishwakarma/compare/v0.0.15...v0.0.14)] - 2019-04-03]

### Added
- Add terratest script for eks example/eks-cluster
- Add tag parameter for autoscaler within eks
- Change the auth config management by refering to another [eks terraform module](https://github.com/terraform-aws-modules/terraform-aws-eks)

### Changed
- Upgrade eks to algin with the latest official worker group provision method
- The eks worker group changed AMI from CoreOS to official EKS AMI

## [[v0.0.14](https://github.com/getamis/vishwakarma/compare/v0.0.14...v0.0.13)] - 2019-03-28]

### Added
- Master work group now support AWS launch template
- The Load Balancer of Master apiserver can choose public/private by variable `endpoint_public_access`
- Add a testing script for example elastikube-cluster through terratest

### Changed
- Change the folder structure for Terratest, all the module migrate to folder modules

## [[v0.0.13](https://github.com/getamis/vishwakarma/compare/v0.0.13...v0.0.12)] - 2019-03-22]

### Added
- Add variable `allowed_ssh_cidr` for control the CIDR to login worker's ssh

### Changed
- Rename variable `version` to `kubernetes_version` and `node_exporter_version`

## [[v0.0.12](https://github.com/getamis/vishwakarma/compare/v0.0.12...v0.0.11)] - 2019-02-26]

### Added
- Block AWS S3 public access

### Changed
- Upgrade aws provider version to 1.60.0

## [[v0.0.11](https://github.com/getamis/vishwakarma/compare/v0.0.11...v0.0.10)] - 2018-12-18]

### Added
- Upgrade Kubernetes from v1.10.5 to v1.13.1
- Replace Kube-Dns with CoreDNS
- Adopt AWS new mixed instance policy for worker asg
- Add new ign for support Kubernetes auditing

### Changed


## [[v0.0.10](https://github.com/getamis/vishwakarma/compare/v0.0.10...v0.0.9)] - 2018-09-19]

### Added
- Support AWS IAM Authenticator

### Changed

## [[v0.0.9](https://github.com/getamis/vishwakarma/compare/v0.0.9...v0.0.8)] - 2018-06-24]

### Added

### Changed
- refactor ignition


## [[v0.0.8](https://github.com/getamis/vishwakarma/compare/v0.0.8...v0.0.7)] - 2018-06-24]

### Added

### Changed
- refactor worker iam role

## [[v0.0.7](https://github.com/getamis/vishwakarma/compare/v0.0.7...v0.0.6)] - 2018-08-02]

### Added

### Changed
- move ignition directory out of aws folder
- bug fix: k8s master, node need to update local CA at beginning
- bug fix: add flannel port for worker sg

## [[v0.0.6](https://github.com/getamis/vishwakarma/compare/v0.0.6...v0.0.5)] - 2018-08-01]

### Added

### Changed
- bug fix: let user add customized sg into apiserver lb sg
- bug fix: unify role name

## [[v0.0.5](https://github.com/getamis/vishwakarma/compare/v0.0.5...v0.0.4)] - 2018-07-31]

### Added
- module kube-worker-spot: k8s spot worker group for self-hosted k8s

### Changed

## [[v0.0.4](https://github.com/getamis/vishwakarma/compare/v0.0.4...v0.0.3)] - 2018-07-26]

### Added
- module aws/kube-master: aws self-hosted k8s master
- module aws/kube-etcd: etcd cluster for aws/kube-master
- module aws/kube-worker-general: k8s general worker group for self-hosted k8s
- module aws/elastickube: the module wrap aws/kube-master and aws/kube-etcd

### Changed


## [[v0.0.3](https://github.com/getamis/vishwakarma/compare/v0.0.3...v0.0.2)] - 2018-06-24]

### Added

- module aws/eks/worker-asg: EKS worker node group by AWS auto scaling group
- moduld aws/eks/worker-spot: EKS worker node group by AWS spot fleet
- example eks_worker: use module aws/network, aws/eks/master, aws/eks/worker-asg and aws/eks/worker-spot to create complete Kubernetes cluster
- document VARIABLES.md: detail variable inputs for module aws/network, aws/eks/master, aws/eks/worker-asg and aws/eks/worker-spot
- document CHANGELOG.md: initial

### Changed

- module aws/eks/master: create a fake Kubernetes ConfigMaps aws-auth

## [[v0.0.2](https://github.com/getamis/vishwakarma/compare/v0.0.3...v0.0.1)] - 2018-06-23]

### Added

- module aws/eks/master: create EKS cluster
- example eks_cluster: use module aws/network and aws/eks/master to create EKS cluster

## [v0.0.1] - 2018-06-16]

### Added

- module aws/network: create AWS completed network environment


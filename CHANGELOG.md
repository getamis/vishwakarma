# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

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


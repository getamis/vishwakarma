# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).


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


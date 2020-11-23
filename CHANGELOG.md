# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="v1.0.3"></a>
## [v1.0.3] - 2020-11-23
FEATURES:
- Upgrade default Kubernetes to 1.19.4
- Remove the load balancer control from worker group's autoscaling group

<a name="v1.0.2"></a>
## [v1.0.2] - 2020-11-11
FEATURES:
- Refactory IAM role for bastion, etcd, master and worker node
- K8s master and worker node AWS ASG support multiple instance type
- Upgrade Terraform AWS provider to the latest version
- Modify IAM and IRSA example for easier to get start

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
- move etcd and Kubernetes ignition to new repos ([#82](https://github.com/getamis/vishwakarma/issues/82))

REFACTORS:
- refactor aws iam auth and irsa module ([#88](https://github.com/getamis/vishwakarma/issues/88))

ENHANCEMENTS:
- update etcd and kubernetes ignition source ([#87](https://github.com/getamis/vishwakarma/issues/87))
- update README.md ([#85](https://github.com/getamis/vishwakarma/issues/85))

TESTS:
- make sure that tests run in different region ([#47](https://github.com/getamis/vishwakarma/issues/47))


[Unreleased]: https://github.com/getamis/vishwakarma/compare/v1.0.1...HEAD
[v1.0.1]: https://github.com/getamis/vishwakarma/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/getamis/vishwakarma/compare/v0.0.16...v1.0.0

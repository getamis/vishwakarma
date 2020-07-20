locals {
  default_kubernetes_version = "v1.18.6"

  binaries = merge({
    kubelet = {
      source   = "https://storage.googleapis.com/kubernetes-release/release/${local.default_kubernetes_version}/bin/linux/amd64/kubelet"
      checksum = "sha512-04ad4a6436642fc033a059e60ee1b96accf06450cc1d1c726321e2cd160210e9bea8f715258c177facf9f1404439a1904d89834584d3c1a76de3d151375d01cd"
    }
    kubectl = {
      source   = "https://storage.googleapis.com/kubernetes-release/release/${local.default_kubernetes_version}/bin/linux/amd64/kubectl"
      checksum = "sha512-2d523472d0caef364ca6fbdabb696a67d93aa108b13597e396d35027681345b52a36f88e7b7e1a63620b5ca0dcbc954c7320dc23a84c7d0f2019bf2c76e6065d"
    }
    cni_plugin = {
      source   = "https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz"
      checksum = "sha512-76b29cc629449723fef45db6a6999b0617e6c9084678a4a3361caf3fc5e935084bc0644e47839b1891395e3cec984f7bfe581dd9455c4991ddeee1c78392e538"
    }
  }, var.binaries)

  containers = merge({
    kube_apiserver = {
      repo = "k8s.gcr.io/kube-apiserver"
      tag  = local.default_kubernetes_version
    }
    kube_controller_manager = {
      repo = "k8s.gcr.io/kube-controller-manager"
      tag  = local.default_kubernetes_version
    }
    kube_scheduler = {
      repo = "k8s.gcr.io/kube-scheduler"
      tag  = local.default_kubernetes_version
    }
    kube_proxy = {
      repo = "k8s.gcr.io/kube-proxy"
      tag  = local.default_kubernetes_version
    }
    pause = {
      repo = "k8s.gcr.io/pause"
      tag  = "3.2"
    }
    cfssl = {
      repo = "quay.io/amis/cfssl"
      tag  = "v1.4.1"
    }
    coredns = {
      repo = "coredns/coredns"
      tag  = "1.7.0"
    }
    vpc_cni = {
      repo = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni"
      tag  = "v1.6.0"
    }
    calico_node = {
      repo = "quay.io/calico/node"
      tag  = "v3.8.1"
    }
    calico_typha = {
      repo = "quay.io/calico/typha"
      tag  = "v3.8.1"
    }
    calico_autoscaler = {
      repo = "k8s.gcr.io/cluster-proportional-autoscaler-amd64"
      tag  = "1.1.2"
    }
    flannel_cni = {
      repo = "quay.io/coreos/flannel"
      tag  = "v0.12.0-amd64"
    }
  }, var.containers)

  cloud_config = merge({
    // The provider for cloud services. Specify empty string for running with no cloud provider.
    provider = "aws"

    // The path to the cloud provider configuration file. Empty string for no configuration file.
    path = ""
  }, var.cloud_config)

  kubelet_cert = merge({
    algo   = "rsa"
    size   = 2048
    expiry = "87600h"
  }, var.kubelet_cert)

  kubelet_config = merge({
    authentication = {
      anonymous = {
        enabled = false
      }

      webhook = {
        cacheTTL = "2m0s"
        enabled  = true
      }
    }

    authorization = {
      mode = "Webhook"
      webhook = {
        cacheAuthorizedTTL   = "5m0s"
        cacheUnauthorizedTTL = "30s"
      }
    }

    clusterDNS         = [cidrhost(var.service_network_cidr, 10)]
    clusterDomain      = "cluster.local"
    healthzBindAddress = "127.0.0.1"
    healthzPort        = 10248
    maxPods            = "$${MAX_PODS}"
  }, var.kubelet_config)

  kubelet_flags = merge({
    pod-infra-container-image = "${local.containers["pause"].repo}:${local.containers["pause"].tag}"
    volume-plugin-dir         = "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
  }, var.kubelet_flags)

  apiserver_flags = merge({
    insecure-port    = 0
    allow-privileged = true

    // TODO: fix livenessProbe while disabled anonymous auth. 
    // See https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests for more information.
    anonymous-auth                  = true
    authorization-mode              = "Node,RBAC"
    enable-admission-plugins        = "NodeRestriction"
    enable-bootstrap-token-auth     = true
    kubelet-preferred-address-types = "InternalIP,ExternalIP,Hostname"
  }, var.apiserver_flags)

  controller_manager_flags = merge({
    leader-elect                    = true
    allocate-node-cidrs             = true
    controllers                     = "*,bootstrapsigner"
    node-monitor-grace-period       = "40s"
    pod-eviction-timeout            = "5m"
    configure-cloud-routes          = false
    use-service-account-credentials = true
  }, var.controller_manager_flags)

  scheduler_flags = merge({
    leader-elect = true
  }, var.scheduler_flags)

  audit_log_flags = merge({
    audit-log-maxage    = 30
    audit-log-maxbackup = 3
    audit-log-maxsize   = 128
  }, var.audit_log_flags)

  coredns_config = merge({
    replicas                 = 2
    cluster_dns_ip           = cidrhost(var.service_network_cidr, 10)
    cluster_domain           = local.kubelet_config["clusterDomain"]
    reverse_cirds            = var.service_network_cidr
    upstream_nameserver      = "/etc/resolv.conf"
    located_on_the_same_host = false
  }, var.coredns_config)

  kube_proxy_config = merge({
    bindAddress = "0.0.0.0"
    clusterCIDR = var.pod_network_cidr
    mode        = "iptables"
  }, var.kube_proxy_config)

  oidc_config = merge({
    issuer        = ""
    api_audiences = ""
  }, var.oidc_config)
}

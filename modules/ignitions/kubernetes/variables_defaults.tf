locals {
  container = merge({
    hyperkube = {
      repo = "gcr.io/google-containers/hyperkube-amd64"
      tag  = "v1.18.5"
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
  }, var.container)

  kubeconfig_paths = merge({
    scheduler          = "/etc/kubernetes/scheduler.conf"
    controller_manager = "/etc/kubernetes/controller-manager.conf"
    kubelet            = "/etc/kubernetes/kubelet.conf"
    bootstrap_kubelet  = "/etc/kubernetes/bootstrap-kubelet.conf"
  }, var.kubeconfig_paths)

  cloud_config = merge({
    // The provider for cloud services. Specify empty string for running with no cloud provider.
    provider = "aws"

    // The path to the cloud provider configuration file. Empty string for no configuration file.
    path = ""
  }, var.cloud_config)

  kubelet_config = merge({
    authentication = {
      anonymous = {
        enabled = false
      }
      webhook = {
        cacheTTL = "0s"
        enabled  = true
      }
      x509 = {
        clientCAFile = "/etc/kubernetes/pki/ca.crt"
      }
    }

    authorization = {
      mode = "Webhook"
      webhook = {
        cacheAuthorizedTTL   = "0s"
        cacheUnauthorizedTTL = "0s"
      }
    }

    clusterDNS         = [cidrhost(var.service_network_cidr, 10)]
    clusterDomain      = "cluster.local"
    healthzBindAddress = "127.0.0.1"
    healthzPort        = 10248
    staticPodPath      = "/etc/kubernetes/manifests"
  }, var.kubelet_config)

  kubelet_flags = merge({}, var.kubelet_flags)

  apiserver_flags = merge({
    allow-privileged                = true
    anonymous-auth                  = false
    authorization-mode              = "Node,RBAC"
    enable-admission-plugins        = "NodeRestriction"
    enable-bootstrap-token-auth     = true
    kubelet-preferred-address-types = "InternalIP,ExternalIP,Hostname"
  }, var.apiserver_flags)

  controller_manager_flags = merge({
    allocate-node-cidrs             = true
    leader-elect                    = true
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
    audit-policy-file   = "/etc/kubernetes/config/policy.yaml"
    audit-log-path      = "/var/log/kubernetes/kube-apiserver-audit.log"
    audit-log-maxage    = 30
    audit-log-maxbackup = 3
    audit-log-maxsize   = 128
  }, var.audit_log_flags)

  coredns_config = merge({
    replicas                 = 2
    cluster_dns_ip           = local.kubelet_config["clusterDNS"][0]
    cluster_domain           = local.kubelet_config["clusterDomain"]
    reverse_cirds            = var.service_network_cidr
    upstream_nameserver      = "/etc/resolv.conf"
    located_on_the_same_host = false
  }, var.coredns_config)

  kube_proxy_config = merge({
    bindAddress = "0.0.0.0"
    clientConnection = {
      kubeconfig = "/var/lib/kube-proxy/kubeconfig.conf"
    }
    clusterCIDR      = var.pod_network_cidr
    mode             = "iptables"
    configSyncPeriod = "0s"
  }, var.kube_proxy_config)

  oidc_confg = merge({
    issuer        = ""
    api_audiences = ""
  }, var.oidc_confg)
}

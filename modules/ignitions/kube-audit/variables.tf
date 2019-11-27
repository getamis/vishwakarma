variable "state_path" {
  description = "Persisted TLS certificate and keys."
  type        = string
  default     = "/var/aws-iam-authenticator"
}

variable "audit_policy_path" {
  description = "A path for autit policy file."
  type        = string
  default     = "/etc/kubernetes/audit"
}

variable "audit_policy" {
  description = "The policy for auditing log."
  type        = string
  default     = <<EOF
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF
}
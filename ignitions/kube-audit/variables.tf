variable "state_path" {
  type        = "string"
  default     = "/var/aws-iam-authenticator"
  description = "Persisted TLS certificate and keys."
}

variable "audit_policy_path" {
  type        = "string"
  default     = "/etc/kubernetes/audit"
  description = "A path for autit policy file."
}

variable "audit_policy" {
  type        = "string"
  default     = <<EOF
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF
  description = "The policy for auditing log."
}
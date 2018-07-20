output "certificate_authority" {
  value = "${base64encode(module.kube_root_ca.cert_pem)}"
}

output "endpoint" {
  value = "https://${aws_elb.master_internal.dns_name}"
}

output "worker_sg_ids" {
  value = ["${aws_security_group.workers.id}"]
}

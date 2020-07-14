output "files" {
  value = [
    data.ignition_file.kubeconfig.rendered,
  ]
}

output "content" {
  value = coalesce(var.content, data.ignition_file.kubeconfig.content[0].content)
}

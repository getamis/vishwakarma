output "files" {
  value = [
    data.ignition_file.addon_manager_pod.rendered,
  ]
}


data "template_file" "docker_dropin" {
  template = file("${path.module}/resources/dropins/10-dockeropts.conf")

  vars = {
    docker_opts = join(" ", var.docker_opts)
  }
}

data "ignition_systemd_unit" "docker_dropin" {
  name    = "docker.service"
  enabled = true

  dropin {
      name    = "10-dockeropts.conf"
      content = data.template_file.docker_dropin.rendered
  }
}

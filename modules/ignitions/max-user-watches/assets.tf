data "template_file" "max_user_watches" {
  template = file("${path.module}/resources/sysctl.d/max-user-watches.conf")

  vars = {
    max_user_watches = var.max_user_watches
  }
}

data "ignition_file" "max_user_watches" {
  path = "/etc/sysctl.d/10-max-user-watches.conf"
  mode = 420

  content {
    content = data.template_file.max_user_watches.rendered
  }
}

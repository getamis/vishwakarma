data "template_file" "ntp_dropin" {
  template = file("${path.module}/resources/systemd/timesyncd.conf.d/10-timesyncd.conf")

  vars {
    ntp_servers = join(" ", var.ntp_servers)
  }
}

data "ignition_file" "ntp_dropin" {
  path = "/etc/systemd/timesyncd.conf.d/10-timesyncd.conf"
  mode = 420

  content {
    content = data.template_file.ntp_dropin.rendered
  }
}

job "nomad_federation" {
  datacenters = ["${region}a","${region}b","${region}c"]
  type = "batch"

  task "wan_join" {
    constraint {
      attribute = "$${meta.type}"
      value     = "server"
    }
    driver = "exec"
    template {
      data = <<EOH
#!/bin/bash
source /etc/profile.d/nomad.sh
/usr/local/bin/nomad server join nomad-server.service.${target_region}.consul:4648
EOH
      destination = "local/run.sh"
      perms = "755"
    }
    config {
      command = "bash"
      args    = ["local/run.sh"]
    }
  }
}
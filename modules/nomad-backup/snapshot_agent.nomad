job "nomad_backup" {
  multiregion {
%{ for region in multiregion }
    region  "${region}" {
      datacenters = ["${region}a","${region}b","${region}c"]
      count = 2
    }
%{ endfor ~}
  }
  type = "service"
  namespace = "${namespace}"

  task "nomad-snapshot" {
    constraint {
      attribute = "$${meta.type}"
      value     = "server"
    }
    driver = "exec"
    template {
      data = <<EOH
${config}
EOH
      destination = "local/agent_config.hcl"
      perms = "755"
    }
    template {
      data = <<EOH
#!/bin/bash
source /etc/profile.d/nomad.sh
/usr/local/bin/nomad operator snapshot agent agent_config.hcl
EOH
      destination = "local/nomad-snapshot-run.sh"
      perms = "755"
    }
    config {
      command = "bash"
      args    = ["local/nomad-snapshot-run.sh"]
    }
  }
}
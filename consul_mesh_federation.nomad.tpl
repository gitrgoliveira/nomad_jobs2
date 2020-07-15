job "consul_federation" {
  datacenters = ["${region}a","${region}b","${region}c"]
  type = "batch"

  task "wan_join" {
    constraint {
      attribute = "$${meta.type}"
      value     = "server"
    }
    template {
      data = <<EOH
#!/bin/bash
consul tls ca create

consul-agent-ca.pem
consul-agent-ca-key.pem

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
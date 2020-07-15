
job "Consul-Service-Gateways" {
  multiregion {
%{ for region in multiregion }
    region  "${region}" {
      datacenters = ["${region}a","${region}b","${region}c"]
    }
%{ endfor ~}
  }
  namespace = "${namespace}"
  type = "system"

  task "consul-mesh-gateway" {

    driver = "exec"

    template {
      data = <<EOH
set -v

consul connect envoy \
  -register \
  -gateway="mesh" \
  -service="gateway" \
  -address "$(private_ip):8700" \
  -wan-address "$(public_ip):8700" \
  -admin-bind "127.0.0.1:19005"
EOH

      destination = "script.sh"
      perms = "755"
    }

    config {
      command = "bash"
      args    = ["script.sh"]
    }
  }

}





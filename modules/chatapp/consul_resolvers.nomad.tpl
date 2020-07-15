job "Consul-Resolvers" {
  multiregion {
%{ for region in multiregion }
    region  "${region}" {
      datacenters = ["${region}a","${region}b","${region}c"]
    }
%{ endfor ~}
  }
  namespace = "${namespace}"

  type = "batch"
  task "resolver-for-mongodb" {
    driver = "raw_exec"
    template {
      data = <<EOH
set -v
echo "==> Create Proxy defaults so that all services use gateway"
sudo tee /mnt/consul/proxy-defaults.hcl > /dev/null <<EOF
Kind = "proxy-defaults"
Name = "global"
MeshGateway = {
  mode = "local"
}
EOF

echo "==> Create Service defaults to make MongoDB use a gateway"
sudo tee /mnt/consul/mongodb.hcl > /dev/null <<EOF
Kind = "service-defaults"
Name = "mongodb"
MeshGateway = {
  mode = "local"
}
EOF

echo "==> Create a Service Router to route Mongodb from DC2 to DC1"
sudo tee /mnt/consul/mongodb-resolver.hcl > /dev/null <<EOF
kind = "service-resolver"
name = "mongodb"
redirect {
service    = "mongodb"
  datacenter = "demo1"
}
EOF

consul config write /mnt/consul/proxy-defaults.hcl
consul config write /mnt/consul/mongodb.hcl
consul config write /mnt/consul/mongodb-resolver.hcl

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
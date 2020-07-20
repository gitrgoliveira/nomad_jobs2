
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
  task "resolver-for-countapi" {

    driver = "exec"

    template {
      data = <<EOH
set -v

cat << EOF >  proxy-defaults.json
{
  "Kind": "proxy-defaults",
  "Name": "global",
  "MeshGateway" : {
    "mode" : "local"
  }
}
EOF

cat << EOF > count-api.hcl
Kind = "service-defaults"
Name = "count-api"
Protocol = "http"
MeshGateway = {
  mode = "local"
}
EOF
cat << EOF >  resolver.hcl
kind = "service-resolver"
name = "count-api"

redirect {
  service    = "count-api"
  datacenter = "eu-west-2"
}
EOF

consul config write proxy-defaults.json
consul config write count-api.hcl
consul config write resolver.hcl

curl http://127.0.01:8500/v1/query \
    --request POST \
    --data \
'{
  "Name": "",
  "Template": {
    "Type": "name_prefix_match"
  },
  "Service": {
    "Service": "$${name.full}",
    "Failover": {
      "NearestN": 3
    }
  }
}'
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





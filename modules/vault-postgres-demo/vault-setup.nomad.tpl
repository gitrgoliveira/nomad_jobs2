
job "vault-postgres-setup" {
  multiregion {
%{ for region in multiregion }
    region  "${region}" {
      datacenters = ["${region}a","${region}b","${region}c"]
    }
%{ endfor ~}
  }
  namespace = "${namespace}"

  type = "batch"
  task "vault-postgres-setup" {
    vault {
      policies =["superuser"]
    }

    driver = "exec"

    template {
      left_delimiter = "::"
      right_delimiter = ";;"
      data = <<EOH
set -v
export VAULT_ADDR=https://vault.service.consul:8200

vault secrets enable database || true
vault write database/config/postgresql  \
 plugin_name=postgresql-database-plugin \
 connection_url="postgresql://{{username}}:{{password}}@postgres.service.consul:5432/postgres?sslmode=disable" \
 allowed_roles="*" username="root" password="rootpassword"


tee readonly.sql > /dev/null<<EOF
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
EOF

vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements=@readonly.sql \
  default_ttl=15s max_ttl=5m

vault read database/creds/readonly
vault read -wrap-ttl=10m database/creds/readonly

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






job "vault-ldap-setup" {
  multiregion {
%{ for region in multiregion }
    region  "${region}" {
      datacenters = ["${region}a","${region}b","${region}c"]
    }
%{ endfor ~}
  }
  namespace = "${namespace}"

  type = "batch"
  task "vault-ldap-setup" {
    vault {
      policies =["superuser"]
    }

    driver = "exec"

    template {
      data = <<EOH
set -v
vault auth enable -tls-skip-verify ldap || true

vault write -tls-skip-verify auth/ldap/config \
    url="ldap://ldap-service.service.consul" \
    binddn="cn=admin,dc=example,dc=org" \
    userattr="uid" \
    bindpass='admin' \
    userdn="ou=Users,dc=example,dc=org" \
    groupdn="ou=Groups,dc=example,dc=org" \
    insecure_tls=true

vault auth list -tls-skip-verify -format=json  | jq -r '.["ldap/"].accessor' > accessor.txt

vault write -tls-skip-verify identity/group name="approvers" \
      policies="superuser" \
      type="external"

vault read -tls-skip-verify identity/group/name/approvers  -format=json | jq -r .data.id > approvers_group_id.txt

vault write -tls-skip-verify identity/group-alias name="approvers" \
        mount_accessor=$(cat accessor.txt) \
        canonical_id=$(cat approvers_group_id.txt)

vault write -tls-skip-verify identity/group name="requesters" \
      policies="test" \
      type="external"

vault read -tls-skip-verify identity/group/name/requesters  -format=json | jq -r .data.id > requesters_group_id.txt

vault write -tls-skip-verify identity/group-alias name="requesters" \
        mount_accessor=$(cat accessor.txt) \
        canonical_id=$(cat requesters_group_id.txt)

vault kv put -tls-skip-verify kv/cgtest example=value


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





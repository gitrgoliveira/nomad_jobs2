resource "nomad_namespace" "vault-demo" {
  provider    = nomad.primary
  name        = "vault-demo"
  description = "Namespace for Vault demos."
}
resource "nomad_namespace" "vault-demo-2" {
  depends_on  = [nomad_job.nomad_federation]
  provider    = nomad.secondary
  name        = "vault-demo"
  description = "Namespace for Vault demos."
}

module "nginx-pki-mr" {
  source = "./modules/nginx-pki-mr"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region,
    data.terraform_remote_state.demostack.outputs.Secondary_Region
  ]
  namespace = nomad_namespace.vault-demo.name
}

module "vault-ldap-demo" {
  source = "./modules/vault-ldap-demo"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region,
    data.terraform_remote_state.demostack.outputs.Secondary_Region
  ]
  namespace = nomad_namespace.vault-demo.name
}

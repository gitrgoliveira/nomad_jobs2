
resource "nomad_namespace" "vault-demo" {
  provider   = nomad.primary
  name        = "vault-demo"
  description = "Namespace for Vault demos."
}
resource "nomad_namespace" "vault-demo-2" {
  provider   = nomad.secondary
  name        = "vault-demo"
  description = "Namespace for Vault demos."
}

module "nginx-pki-mr" {
  source = "./modules/nginx-pki-mr"
  providers = {
    nomad = nomad.primary
  }
  multi_region = [
    data.terraform_remote_state.demostack.outputs.Primary_Region,
    data.terraform_remote_state.demostack.outputs.Secondary_Region
  ]
  namespace = "vault-demo"
}
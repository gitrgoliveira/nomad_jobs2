resource "nomad_namespace" "nomad-demo" {
  provider   = nomad.primary
  name        = "nomad-demo"
  description = "Namespace for Nomad demos."
}
resource "nomad_namespace" "nomad-demo-2" {
  provider   = nomad.secondary
  name        = "nomad-demo"
  description = "Namespace for Nomad demos."
}

# module "nomad-backup" {
#   source = "./modules/nomad-backup"
#   providers = {
#     nomad = nomad.primary
#   }
#   multiregion = [
#     data.terraform_remote_state.demostack.outputs.Primary_Region,
#     data.terraform_remote_state.demostack.outputs.Secondary_Region
#   ]
#   namespace = nomad_namespace.nomad-demo.name
# }

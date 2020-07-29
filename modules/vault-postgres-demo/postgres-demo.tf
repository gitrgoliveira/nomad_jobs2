
module "pgadmin4" {
  source = "../pgadmin4"
  providers = {
    nomad = nomad
  }
  multiregion = var.multiregion
  namespace   = var.namespace
}

module "postgres" {
  source = "../postgres"
  providers = {
    nomad = nomad
  }
  multiregion = var.multiregion
  namespace   = var.namespace
}

# Debug
# resource "local_file" "foo" {
#   depends_on  = [module.postgres]
#   content     = templatefile("${path.module}/vault-setup.nomad.tpl", {
#     multiregion = var.multiregion
#     namespace   = var.namespace
#   })
#   filename = "${path.module}/vault-setup.nomad"
# }

resource "nomad_job" "vault-setup" {
  provider   = nomad
  depends_on = [module.postgres]
  jobspec = templatefile("${path.module}/vault-setup.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}
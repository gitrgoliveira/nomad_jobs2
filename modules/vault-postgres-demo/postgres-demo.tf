
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

resource "nomad_job" "vault-setup" {
  provider = nomad
  jobspec = templatefile("${path.module}/vault-setup.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}
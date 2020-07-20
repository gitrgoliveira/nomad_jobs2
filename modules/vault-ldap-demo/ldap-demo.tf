
module "openldap" {
  source = "../openldap"
  providers = {
    nomad = nomad
  }
  multiregion = var.multiregion
  namespace   = var.namespace
}

module "phpldapadmin" {
  source = "../phpldapadmin"
  providers = {
    nomad = nomad
  }
  multiregion = var.multiregion
  namespace   = var.namespace
}

resource "nomad_job" "vault-setup" {
  provider = nomad
  jobspec = templatefile("${path.module}/vault-setup.nomad.tpl", {
    multiregion = [var.multiregion[0]]
    namespace   = var.namespace
  })
}
module "count-api" {
  source = "../count-api"
  providers = {
    nomad = nomad
  }
  multiregion = [var.multiregion[0]]
  namespace   = var.namespace
}

module "count-dashboard" {
  source = "../count-dashboard"
  providers = {
    nomad = nomad
  }
  multiregion = var.multiregion
  namespace   = var.namespace
}

resource "nomad_job" "count-dashboard" {
  provider = nomad
  jobspec = templatefile("${path.module}/consul-resolvers.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}
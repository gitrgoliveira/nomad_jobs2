resource "nomad_job" "phpldapadmin" {
  provider = nomad
  jobspec = templatefile("${path.module}/phpldapadmin.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}
resource "nomad_job" "pgadmin" {
  provider = nomad
  jobspec = templatefile("${path.module}/pgadmin.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}
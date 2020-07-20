resource "nomad_job" "count-api" {
  provider = nomad
  jobspec = templatefile("${path.module}/countapi.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}
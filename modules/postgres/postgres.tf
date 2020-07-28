resource "nomad_job" "postgres" {
  provider = nomad
  jobspec = templatefile("${path.module}/postgresql.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}

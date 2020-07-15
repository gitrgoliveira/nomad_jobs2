resource "nomad_job" "count-dashboard" {
  provider = nomad
  jobspec  = templatefile("${path.module}/countdashboard.nomad.tpl", {
    multiregion = var.multiregion
    namespace = var.namespace
  })
}
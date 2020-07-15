resource "nomad_job" "fabio-lb" {
  provider = nomad
  jobspec  = templatefile("${path.module}/fabio-lb.nomad", {
    multiregion = var.multiregion
  })
}
resource "nomad_job" "fabio-lb" {
  provider = nomad
  jobspec  = templatefile("${path.module}/fabio-lb.nomad", {
    multi_region = var.multi_region
  })
}
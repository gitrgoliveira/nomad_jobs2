resource "nomad_job" "nginx-pki-mr" {
  provider = nomad
  jobspec = templatefile("${path.module}/nginx-pki.nomad", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}

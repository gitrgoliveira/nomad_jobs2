resource "nomad_job" "nginx-pki-mr" {
  provider = nomad
  jobspec  = templatefile("${path.module}/nginx-pki.nomad", {
    multi_region = var.multi_region
    namespace = var.namespace
  })
}

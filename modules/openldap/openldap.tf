resource "nomad_job" "openldap" {
  provider = nomad
  jobspec = templatefile("${path.module}/openldap.nomad.tpl", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}
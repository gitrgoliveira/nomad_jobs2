resource "nomad_job" "consul-mesh-gateway" {
  provider = nomad
  jobspec = templatefile("${path.module}/consul-mesh-gateway.nomad", {
    multiregion = var.multiregion
    namespace   = var.namespace
  })
}

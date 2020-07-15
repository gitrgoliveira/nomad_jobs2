
resource "nomad_job" "mongodb" {
  provider = nomad
  jobspec  = templatefile("${path.module}/mongodb.nomad.tpl", {
    multiregion = [ var.multiregion[0] ]
    namespace = var.namespace
  })
}
resource "nomad_job" "consul_resolvers" {
  depends_on = [ nomad_job.mongodb ]
  provider = nomad
  jobspec  = templatefile("${path.module}/consul_resolvers.nomad.tpl", {
    multiregion = [ var.multiregion[0] ]
    namespace = var.namespace
  })
}
resource "nomad_job" "chatapp_multiregion" {
  depends_on = [ nomad_job.consul_resolvers ]
  provider = nomad
  jobspec  = templatefile("${path.module}/chatapp_multiregion.nomad.tpl", {
    multiregion = var.multiregion
    namespace = var.namespace
  })
}

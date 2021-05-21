
resource "nomad_job" "boundary-postgres" {
  provider = nomad
  jobspec = file("${path.module}/boundary-postgres.nomad")
  detach     = false
  purge_on_destroy = true
}

resource "nomad_job" "boundary-controller" {
  provider = nomad
  jobspec = file("${path.module}/boundary-controller.nomad")
  depends_on  = [nomad_job.boundary-postgres]
  detach     = false
  purge_on_destroy = true
}

resource "nomad_job" "boundary-worker" {
  provider = nomad
  jobspec = file("${path.module}/boundary-worker.nomad")
  detach     = false
  purge_on_destroy = true
  depends_on  = [nomad_job.boundary-controller]
}

# reading boundary configuration
data "consul_keys" "boundary" {
  key {
    name    = "boundary-init"
    path    = "service/boundary/boundary-init"
  }
  depends_on  = [nomad_job.boundary-worker]
}

output "boundary_config"{
  value = jsondecode(data.consul_keys.boundary.var.boundary-init)
}
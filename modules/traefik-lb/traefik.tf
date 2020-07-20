resource "nomad_job" "traefik-mr" {
  provider = nomad
  jobspec = templatefile("${path.module}/traefik.nomad", {
    multiregion = var.multiregion
  })
}

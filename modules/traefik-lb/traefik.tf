resource "nomad_job" "traefik-mr" {
  provider = nomad
  jobspec  = templatefile("${path.module}/traefik.nomad", {
    multi_region = var.multi_region
  })
}

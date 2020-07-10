resource "nomad_job" "nginx-pki" {
  provider = nomad
  jobspec  = templatefile("${path.module}/nginx-pki.nomad.tmpl", {
    region = var.region
  })
}


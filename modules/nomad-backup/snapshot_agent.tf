resource "nomad_job" "nomad-backup" {
  provider = nomad
  jobspec  = templatefile("${path.module}/snapshot_agent.nomad", {
    multiregion = var.multiregion
    namespace = var.namespace
    config = file("${path.module}/agent_config.hcl")
  })
}

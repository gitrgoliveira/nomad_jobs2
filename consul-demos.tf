
resource "nomad_namespace" "consul-demo" {
  provider   = nomad.primary
  name        = "consul-demo"
  description = "Namespace for Consul demos."
}
resource "nomad_namespace" "consul-demo-2" {
  provider   = nomad.secondary
  name        = "consul-demo"
  description = "Namespace for Consul demos."
}

locals {
  fabio  = "${data.terraform_remote_state.demostack.outputs.Primary_Fabio}"
}

module "prometheus-mr" {
  source = "./modules/prometheus"
  providers = {
    nomad = nomad.primary
  }
  multi_region = [
    data.terraform_remote_state.demostack.outputs.Primary_Region
  ]
  namespace = nomad_namespace.consul-demo.name
  lb_https_address = local.fabio
}



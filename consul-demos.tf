
resource "nomad_namespace" "consul-demo" {
  provider    = nomad.primary
  name        = "consul-demo"
  description = "Namespace for Consul demos."
}
resource "nomad_namespace" "consul-demo-2" {
  depends_on  = [nomad_job.nomad_federation]
  provider    = nomad.secondary
  name        = "consul-demo"
  description = "Namespace for Consul demos."
}

locals {
  fabio = "${data.terraform_remote_state.demostack.outputs.Primary_Fabio}"
}

module "prometheus-mr" {
  source = "./modules/prometheus"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region
  ]
  namespace        = nomad_namespace.consul-demo.name
  lb_https_address = local.fabio
}

module "consul-mesh-gateway" {
  source = "./modules/consul-mesh-gateway"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region
  ]
  namespace = nomad_namespace.consul-demo.name
}
module "consul-mesh-gateway2" {
  source = "./modules/consul-mesh-gateway"
  providers = {
    nomad = nomad.secondary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Secondary_Region
  ]
  namespace = nomad_namespace.consul-demo.name
}

module "chatapp" {
  source = "./modules/chatapp"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region
  ]
  namespace = nomad_namespace.consul-demo.name
}

module "count-demo" {
  source = "./modules/count-demo"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region,
    data.terraform_remote_state.demostack.outputs.Secondary_Region
  ]
  namespace = nomad_namespace.consul-demo.name
}
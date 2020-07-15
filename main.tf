// Workspace Data
data "terraform_remote_state" "demostack" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = var.TFE_ORGANIZATION
    workspaces = {
      name = var.DEMOSTACK_WORKSPACE
    }
  } //config
}

# Configure the Nomad providers
provider "nomad" {
  alias   = "primary"
  address = data.terraform_remote_state.demostack.outputs.Primary_Nomad
}
provider "nomad" {
  alias   = "secondary"
  address = data.terraform_remote_state.demostack.outputs.Secondary_Nomad
}

resource "nomad_job" "consul_federation" {
  provider = nomad.primary
  detach   = false
  jobspec = templatefile("./consul_federation.nomad.tpl", {
    region        = data.terraform_remote_state.demostack.outputs.Primary_Region
    target_server = data.terraform_remote_state.demostack.outputs.Secondary_servers_nodes[0]
  })
}

resource "nomad_job" "nomad_federation" {
  provider   = nomad.primary
  depends_on = [nomad_job.consul_federation]
  detach     = false
  jobspec = templatefile("./nomad_federation.nomad.tpl", {
    region        = data.terraform_remote_state.demostack.outputs.Primary_Region
    target_region = data.terraform_remote_state.demostack.outputs.Secondary_Region
  })
}

module "fabio-lb-mr" {
  source = "./modules/fabio-lb"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region,
    data.terraform_remote_state.demostack.outputs.Secondary_Region
  ]
}

module "traefik-lb-mr" {
  source = "./modules/traefik-lb"
  providers = {
    nomad = nomad.primary
  }
  multiregion = [
    data.terraform_remote_state.demostack.outputs.Primary_Region,
    data.terraform_remote_state.demostack.outputs.Secondary_Region
  ]
}

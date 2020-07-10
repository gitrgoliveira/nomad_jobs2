resource "nomad_job" "prometheus-mr" {
  provider = nomad
  jobspec  = templatefile("${path.module}/prometheus.nomad.tpl", {
    multi_region = var.multi_region
    namespace = var.namespace
    lb_url = "${var.lb_https_address}"
    lb_srv = substr(var.lb_https_address, 7, length(var.lb_https_address))
    prometheus_config = file("${path.module}/prometheus_config.yml")
  })
  detach     = false
}

provider "grafana" {
  url  = "${var.lb_https_address}/grafana"
  auth = "admin:admin"
}
resource "grafana_data_source" "prometheus" {
  depends_on = [nomad_job.prometheus-mr]
  type          = "prometheus"
  name          = "prometheus"
  url           = "http://prometheus.service.consul:9090"
  is_default    = "true"
}
resource "grafana_dashboard" "Nomad" {
  depends_on = [nomad_job.prometheus-mr]
  config_json = file("${path.module}/demo_dashboards/Nomad.json")
}
resource "grafana_dashboard" "Consul" {
  depends_on = [nomad_job.prometheus-mr]
  config_json = file("${path.module}/demo_dashboards/Consul.json")
}
resource "grafana_dashboard" "Vault" {
  depends_on = [nomad_job.prometheus-mr]
  config_json = file("${path.module}/demo_dashboards/Vault.json")
}

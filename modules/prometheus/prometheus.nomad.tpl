job "monitoring" {
  multiregion {
%{ for region in multiregion }
    region  "${region}" {
      datacenters = ["${region}a","${region}b","${region}c"]
      count = 1
    }
%{ endfor ~}
  }

  type = "service"
  namespace = "${namespace}"

  group "prometheus-grafana" {
    ephemeral_disk {
      size = 300
    }

    vault {
      policies = ["superuser"]
    }

    restart {
      attempts = 0
      mode     = "fail"
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"
        data = <<EOH
${prometheus_config}
EOH
            }
            driver = "docker"
            # artifact {
            #     source = "https://raw.githubusercontent.com/GuyBarros/nomad_jobs/master/prometheus/prometheus.yml"
            #     destination = "/opt/prometheus/config"
            # }
            # docker run -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml \prom/prometheus
            config {
                image = "prom/prometheus"
                network_mode = "host"
                args = [
                    "--web.external-url=${lb_url}/prometheus",
                    "--web.route-prefix=/",
                    "--config.file=/etc/prometheus/prometheus.yml",
                    "--storage.tsdb.retention.size=150GB",
                #     # "--storage.tsdb.path=/opt/prometheus/data/"
                ]

                volumes = [
                    "local/prometheus.yml:/etc/prometheus/prometheus.yml"
                ]

                port_map {
                     prometheus = 9090
                }
            }

            logs {
                max_files     = 5
                max_file_size = 15
            }
            resources {
                cpu = 500
                memory = 512
                network {
                    mbits = 10
                    port  "prometheus"  {
                        static = 9090
                    }
                }
            }
            service {
                name = "prometheus"
                tags = ["urlprefix-/prometheus  strip=/prometheus"]
                port = "prometheus"
                check {
                    name     = "prometheus port alive"
                    type     = "http"
                    path     = "/-/healthy"
                    interval = "10s"
                    timeout  = "2s"
                }
            }
        }

        task "grafana" {
            driver = "docker"
            meta {
                FABIO_URL = "${lb_srv}"
            }
            env {
                "GF_SERVER_DOMAIN"="${lb_srv}"
                "GF_SERVER_ROOT_URL"="%(protocol)s://%(domain)s/grafana/"
                "GF_DEFAULT_THEME"="light"
            }
            config {
                image = "grafana/grafana"
                network_mode = "host"
                port_map {
                     http = 3000
                }
            }

            logs {
                max_files     = 5
                max_file_size = 15
            }
            resources {
                cpu = 500
                memory = 512
                network {
                    mbits = 10
                    port  "http"  {
                        static = 3000
                    }
                }

            }
            service {
                name = "grafana"
                tags = ["urlprefix-/grafana strip=/grafana"]
                port = "http"
                check {
                    type = "tcp"
                    interval = "10s"
                    timeout = "4s"
                }
            }
        }

   }
}

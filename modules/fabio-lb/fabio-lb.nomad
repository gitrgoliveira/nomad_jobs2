job "fabio" {
  multiregion {
%{ for region in multiregion }
    region  "${region}" {
      datacenters = ["${region}a","${region}b","${region}c"]
    }
%{ endfor ~}
  }
  type     = "system"
  priority = 75

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  task "fabio" {
    driver = "exec"

    config {
      command = "fabio"
    }

    artifact {
      source      = "https://github.com/fabiolb/fabio/releases/download/v1.5.13/fabio-1.5.13-go1.13.4-linux_amd64"
      destination = "fabio"
      mode        = "file"
    }

    service {
      port = "http"
      name = "fabio"

      check {
        type     = "http"
        port     = "ui"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    resources {
      network {
        port "http" {
          static = 9999
        }

        port "ui" {
          static = 9998
        }
      }
    }
  }
}

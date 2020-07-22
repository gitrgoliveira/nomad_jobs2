nomad {
  http_addr       = "https://nomad-server.service.consul:4646"
  token           = ""
# region          = "" defaults to local region
# ca_path         = ""
  ca_file         = "/usr/local/share/ca-certificates/01-me.crt"
  cert_file       = "/etc/ssl/certs/me.crt"
  key_file        = "/etc/ssl/certs/me.key"
  tls_server_name = ""
}

snapshot {
  interval         = "30m"
  retain           = 3
  stale            = false
  service          = "nomad-snapshot"
  deregister_after = "72h"
  lock_key         = "nomad-snapshot/lock"
  max_failures     = 3
  prefix      = "nomad"
}

log {
  level           = "INFO"
  enable_syslog   = false
  syslog_facility = "LOCAL0"
}

consul {
  enabled         = true
  http_addr       = "127.0.0.1:8500"
  token           = ""
  datacenter      = ""
  ca_file         = ""
  ca_path         = ""
  cert_file       = ""
  key_file        = ""
  tls_server_name = ""
}

# one storage block is required

local_storage {
  path = "."
}

# aws_storage {
#   access_key_id     = ""
#   secret_access_key = ""
#   s3_region         = ""
#   s3_endpoint       = ""
#   s3_bucket         = ""
#   s3_key_prefix     = "nomad-snapshot"
# }

# azure_blob_storage {
#   account_name   = ""
#   account_key    = ""
#   container_name = ""
# }

# google_storage {
#   bucket = ""
# }
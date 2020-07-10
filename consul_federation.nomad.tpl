job "consul_federation" {
  datacenters = ["${region}a","${region}b","${region}c"]
  type = "batch"

  task "wan_join" {
    constraint {
      attribute = "$${meta.type}"
      value     = "server"
    }
    driver = "raw_exec"
    config {
      command = "/usr/local/bin/consul"
      args    = ["join","-wan","${target_server}"]
    }
  }
}
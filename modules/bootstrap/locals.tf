locals {
  validators            = [for i in range(var.validator_count) : format("validator-%03d.%s", i + 1, var.base_dn)]
  fullnodes             = [for i in range(var.fullnode_count) : format("fullnode-%03d.%s", i + 1, var.base_dn)]
  hostvars              = concat(local.validators, local.fullnodes)
  blade_home_dir        = "/var/lib/blade"
  blade_p2p_port        = 10001
  loadtest_account      = "0x85da99c8a7c2c95964c8efd687e95e632fc533d6"
  blade_grpc_port       = 10000
  blade_jsonrpc_port    = 10002
  blade_prometheus_port = 9091
  blade_user            = "blade"
  memory_high           = "70%"
  memory_max            = "80%"
  native_token_config   = "Blade:BLADE:18:true"
  bootstrap_dir         = "/tmp/${random_pet.server.id}/bootstrap"
}
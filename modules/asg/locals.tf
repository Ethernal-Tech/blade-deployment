locals {
  devnet_key_name = "${var.base_devnet_key_name}-${var.deployment_name}-${var.network_type}"
  region          = "us-west-2"
  validators            = [for i in range(var.validator_count) : format("validator-%03d.%s", i + 1, var.base_dn)]
  fullnodes             = [for i in range(var.fullnode_count) : format("fullnode-%03d.%s", i + 1, var.base_dn)]
  hostvars              = concat(local.validators, local.fullnodes)
  blade_home_dir        = "/var/lib/blade"
  blade_p2p_port        = 10001
  block_gas_limit       = 10000000
  loadtest_account      = "0x85da99c8a7c2c95964c8efd687e95e632fc533d6"
  block_time            = 5
  chain_id              = 100
  blade_grpc_port       = 10000
  blade_jsonrpc_port    = 10002
  blade_prometheus_port = 9091
  is_bridge_active      = false
  is_london_fork_active = false
  blade_user            = "blade"
  memory_high           = "70%"
  memory_max            = "80%"
  max_slots             = 276480
  max_enqueued          = 276480
  native_token_config   = "Blade:BLADE:18:true"
  docker_image          = "0xethernal/blade:0.0.4"
  node_exporter_port    = 9100
}
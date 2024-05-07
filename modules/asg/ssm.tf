resource "aws_ssm_parameter" "cw_agent_config" {
  count = var.validator_count
  name  = format("/%s/validator-%03d/cw_agent_config",var.deployment_name, count.index + 1)
  type  = "String"
  value = templatefile("${path.module}/scripts/cw_agent.json.tftpl", {
    role = "validator",
    hostname = format("validator-%03d.%s", count.index + 1, var.base_dn)
  })
}

locals {
  validators = [for i in range(var.validator_count) : format("validator-%03d.%s", i + 1, var.base_dn) ]
  fullnodes = [for i in range(var.fullnode_count) : format("fullnode-%03d.%s", i + 1, var.base_dn) ]
  hostvars = concat(local.validators, local.fullnodes)
}

resource "aws_ssm_parameter" "validator_bootstrap" {
  name = format("/%s/bootstrap.sh",var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/bootstrap.sh", {
    hostvars = local.hostvars,
    validators = local.validators,
    fullnodes = local.fullnodes
    blade_home_dir = "/var/lib/blade"
    blade_p2p_port = 10001,
    block_gas_limit =  10000000,
    loadtest_account = "0x85da99c8a7c2c95964c8efd687e95e632fc533d6",
    block_time = 5,
    chain_id = 100,
    native_token_config = "Blade:BLADE:18:true",
    base_dn = "${var.deployment_name}.blade.ethernal.private",
    clean_deploy_title = var.deployment_name
    is_bridge_active = false,
    is_london_fork_active = false
    

  })
  
}

resource "aws_ssm_parameter" "validator_config" {
  name = format("/%s/config.json",var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/config.json", {
    deployment_name = var.deployment_name
  })
}

resource "aws_ssm_parameter" "validator_service" {
  for_each = toset(local.hostvars)

  name = format("/%s/%s.service",var.deployment_name, each.value)
  type = "String"
  value = templatefile("${path.module}/scripts/blade.service", {
    blade_home_dir = "/var/lib/blade"
    deployment_name = var.deployment_name
    blade_p2p_port = 10001
    blade_grpc_port = 10000
    blade_jsonrpc_port = 10002
    blade_prometheus_port = 9091
    block_gas_limit = 10000000
    base_dn = var.base_dn
    hostname = each.value
    is_bootstraper = startswith(each.value, "validator-001") ? false : true,
    blade_user = "blade"
    memory_high = "70%"
    memory_max = "80%"
  })
}
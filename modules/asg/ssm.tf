resource "aws_ssm_parameter" "cw_agent_config" {
  for_each = toset(local.hostvars)
  name  = format("/%s/%s/cw_agent_config", var.deployment_name, each.value)
  type  = "String"
  value = templatefile("${path.module}/scripts/cw_agent.json.tftpl", {
    role     = "validator",
    hostname = each.value
  })
}

resource "aws_ssm_parameter" "validator_bootstrap" {
  name = format("/%s/bootstrap.sh", var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/bootstrap.sh", {
    hostvars              = local.hostvars
    validators            = local.validators
    fullnodes             = local.fullnodes
    blade_home_dir        = local.blade_home_dir
    blade_p2p_port        = local.blade_p2p_port
    block_gas_limit       = local.block_gas_limit
    loadtest_account      = local.loadtest_account
    block_time            = local.block_time
    chain_id              = local.chain_id
    native_token_config   = local.native_token_config
    base_dn               = var.base_dn
    clean_deploy_title    = var.deployment_name
    is_bridge_active      = local.is_bridge_active
    is_london_fork_active = local.is_london_fork_active
    docker_image          = local.docker_image
    bootstrap_dir         = local.bootstrap_dir

  })

}

resource "aws_ssm_parameter" "validator_config" {
  name = format("/%s/config.json", var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/config.json", {
    deployment_name = var.deployment_name
  })
}

resource "aws_ssm_parameter" "validator_service" {
  for_each = toset(local.hostvars)

  name = format("/%s/%s.service", var.deployment_name, each.value)
  type = "String"
  value = templatefile("${path.module}/scripts/blade.service", {
    blade_home_dir        = local.blade_home_dir
    deployment_name       = var.deployment_name
    blade_p2p_port        = local.blade_p2p_port
    blade_grpc_port       = local.blade_grpc_port
    blade_jsonrpc_port    = local.blade_jsonrpc_port
    blade_prometheus_port = local.blade_prometheus_port
    block_gas_limit       = local.block_gas_limit
    base_dn               = var.base_dn
    hostname              = each.value
    is_bootstraper        = startswith(each.value, "validator-001") ? false : true,
    blade_user            = local.blade_user
    memory_high           = local.memory_high
    memory_max            = local.memory_max
    max_slots             = local.max_slots
    max_enqueued          = local.max_enqueued
    docker_image          = local.docker_image
  })
}
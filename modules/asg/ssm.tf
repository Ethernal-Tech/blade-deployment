resource "aws_ssm_parameter" "cw_agent_config" {
  for_each = toset(local.hostvars)
  name  = format("/%s/%s/cw_agent_config", var.deployment_name, each.value)
  type  = "String"
  value = templatefile("${path.module}/scripts/cw_agent.json.tftpl", {
    role     = "validator",
    hostname = each.value
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
    gossip_msg_size       = local.gossip_msg_size
  })
}
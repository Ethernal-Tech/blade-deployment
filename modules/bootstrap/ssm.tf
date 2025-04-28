resource "aws_ssm_parameter" "cw_agent_config" {
  for_each = toset(local.hostvars)
  name     = format("/%s/%s/cw_agent_config", var.deployment_name, each.value)
  type     = "String"
  value = templatefile("${path.module}/scripts/cw_agent.json.tftpl", {
    role     = "validator",
    hostname = each.value,
    region   = var.region
  })
}

resource "aws_ssm_parameter" "validator_config" {
  name = format("/%s/config.json", var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/config.json", {
    deployment_name = var.deployment_name
    region          = var.region
  })
}

resource "aws_ssm_parameter" "validator_service" {
  for_each = toset(local.hostvars)

  name = format("/%s/%s.service", var.deployment_name, each.value)
  type = "String"
  value = templatefile("${path.module}/scripts/blade2.service", {
    blade_home_dir           = local.blade_home_dir
    deployment_name          = var.deployment_name
    blade_p2p_port           = local.blade_p2p_port
    blade_grpc_port          = local.blade_grpc_port
    blade_jsonrpc_port       = local.blade_jsonrpc_port
    blade_prometheus_port    = local.blade_prometheus_port
    block_gas_limit          = var.block_gas_limit
    base_dn                  = var.base_dn
    hostname                 = each.value
    blade_user               = local.blade_user
    memory_high              = local.memory_high
    memory_max               = local.memory_max
    max_slots                = var.max_slots
    max_enqueued             = var.max_enqueued
    docker_image             = var.docker_image
    gossip_msg_size          = var.gossip_msg_size
    price_limit              = var.price_limit
    json_batch_request_limit = local.json_batch_request_limit
    is_bootstraper           = startswith(each.value, "validator-001") ? false : true,
  })
}

resource "aws_ssm_parameter" "test_service" {

  name = format("/%s/fullnode_test.service", var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/blade2.service", {
    blade_home_dir           = local.blade_home_dir
    deployment_name          = var.deployment_name
    blade_p2p_port           = local.blade_p2p_port
    blade_grpc_port          = local.blade_grpc_port
    blade_jsonrpc_port       = local.blade_jsonrpc_port
    blade_prometheus_port    = local.blade_prometheus_port
    block_gas_limit          = var.block_gas_limit
    base_dn                  = var.base_dn
    hostname                 = "fullnode_test"
    blade_user               = local.blade_user
    memory_high              = local.memory_high
    memory_max               = local.memory_max
    max_slots                = var.max_slots
    max_enqueued             = var.max_enqueued
    docker_image             = var.docker_image
    gossip_msg_size          = var.gossip_msg_size
    price_limit              = var.price_limit
    json_batch_request_limit = local.json_batch_request_limit
    is_bootstraper           = false,
  })
}

resource "aws_ssm_parameter" "faucet_service" {


  name = format("/%s/faucet.service", var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/faucet.service", {
    blade_jsonrpc_port = local.blade_jsonrpc_port
    base_dn            = var.base_dn
    memory_high        = local.memory_high
    memory_max         = local.memory_max
    faucet_privkey     = var.faucet_privkey
    faucet_amount      = 5
    faucet_minutes     = 1440
    faucet_port        = 8888
  })
}

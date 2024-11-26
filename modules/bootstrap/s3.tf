resource "aws_s3_bucket" "state" {
  bucket        = "${var.deployment_name}-state-bucket"
  force_destroy = true
  tags = merge(var.default_tags, {
    Name = "State Bucket"
    }
  )
}

resource "aws_s3_object" "validator_bootstrap" {
  bucket = aws_s3_bucket.state.bucket
  key    = format("/%s/bootstrap.sh", var.deployment_name)
  content = templatefile("${path.module}/scripts/bootstrap.sh", {
    hostvars              = local.hostvars
    validators            = local.validators
    fullnodes             = local.fullnodes
    blade_home_dir        = local.blade_home_dir
    blade_p2p_port        = local.blade_p2p_port
    block_gas_limit       = var.block_gas_limit
    loadtest_account      = local.loadtest_account
    block_time            = var.block_time
    chain_id              = var.chain_id
    native_token_config   = local.native_token_config
    base_dn               = var.base_dn
    clean_deploy_title    = var.deployment_name
    is_bridge_active      = var.is_bridge_active
    is_london_fork_active = var.is_london_fork_active
    docker_image          = var.docker_image
    bootstrap_dir         = local.bootstrap_dir
    epoch_reward          = var.epoch_reward

  })

}

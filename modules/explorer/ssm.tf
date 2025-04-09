resource "aws_ssm_parameter" "explorer_env" {
  name = format("/%s/blockscout.env", var.deployment_name)
  type = "String"
  value = templatefile("${path.module}/scripts/blockscout.env", {
    base_dn                = var.base_dn
    blade_jsonrpc_port     = var.blade_jsonrpc_port
    blockscout_db_password = var.blockscout_db_password
    blockscout_db_key_base = ""
    chain_id               = var.chain_id
    blockscout_http_port   = 4000
    blockscout_version     = "6.5.0-beta"

  })
}

resource "aws_ssm_parameter" "cw_agent_config" {
  count = var.validator_count
  name  = format("/%s/validator-%03d/cw_agent_config",var.deployment_name, count.index + 1)
  type  = "String"
  value = templatefile("${path.module}/scripts/cw_agent.json.tftpl", {
    role = "validator",
    hostname = format("validator-%03d.%s", count.index + 1, var.base_dn)
  })
}
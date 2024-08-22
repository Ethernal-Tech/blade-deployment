output "aws_lb_rpc" {
  value = module.elb.aws_lb_ext_rpc_domain
}

output "aws_lb_explorer" {
  value = module.elb.aws_lb_explorer_domain
}

output "aws_lb_smart_contract_veririfer" {
  value = module.elb.aws_lb_smart_contract_verifier_domain
}

output "aws_lb_faucet" {
  value = module.elb.aws_lb_faucet_domain
}

output "aws_grafana_workspace_id" {
  value = module.monitoring.aws_grafana_workspace_monitoring_id
}

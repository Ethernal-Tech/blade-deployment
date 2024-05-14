## Prometheus workspace, required for Grafana to collect all the prometheus metrics 
## ADOT collects metrics and pushes to the endpoint

resource "aws_cloudwatch_log_group" "prometheus" {
  name = "prometheus-logs"
}

resource "aws_prometheus_workspace" "prometheus" {
  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prometheus.arn}:*"
  }
}
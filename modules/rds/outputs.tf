output "aws_rds_cluster_explorer" {
  value = aws_rds_cluster.explorer.*.endpoint
}
output "lifecycle_role" {
  value = aws_iam_role.lifecycle.arn

}

output "sns_topic_arn" {
  value = aws_sns_topic.autoscale_handling.arn

}
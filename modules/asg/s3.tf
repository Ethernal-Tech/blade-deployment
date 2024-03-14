resource "aws_s3_bucket" "state" {
  bucket        = "${var.deployment_name}-state-bucket"
  force_destroy = true
  tags = merge(var.default_tags, {
    Name = "State Bucket"
    }
  )
}
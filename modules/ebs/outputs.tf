output "validator_volume_ids" {
    value = aws_ebs_volume.validator.*.id
  
}
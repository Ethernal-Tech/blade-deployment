resource "aws_dynamodb_table" "example" {
  name           = "Hostnames"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "Hostname"
  # range_key      = "Hostname"

  attribute {
    name = "Hostname"
    type = "S"
  }


  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

resource "aws_dynamodb_table_item" "example" {
  count      = var.validator_count
  table_name = aws_dynamodb_table.example.name
  hash_key   = aws_dynamodb_table.example.hash_key

  item = jsonencode(
    {
      "Hostname" = { "S" = "validator-00${count.index + 1}" },
      "Exists"   = { "BOOL" = false }
    }
  )
  lifecycle {
    ignore_changes = [item]
  }
}
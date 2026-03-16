resource "aws_dynamodb_table" "table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = var.hash_key

  attribute {
    name = var.hash_key
    type = "S" # String
  }
}

# Create a table to hold the lock
resource "aws_dynamodb_table" "gswlab-terraform-state-lock" {
  name           = "gswlab-terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    "Name" = "DynamoDB Table for Terraform State Lock"
  }
}

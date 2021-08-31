resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "BookInfo"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"

  tags = {
    Name        = "dynamodb-table-1"
  }
  attribute {
    name = "UserId"
    type = "N"
  }
}
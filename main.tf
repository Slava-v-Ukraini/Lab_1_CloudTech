module "table_courses" {
  source     = "./modules/dynamodb"
  table_name = "courses"
  hash_key   = "id"
}

module "table_authors" {
  source     = "./modules/dynamodb"
  table_name = "authors"
  hash_key   = "id"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}


data "archive_file" "zip" {
  for_each    = toset(["get-all-authors", "get-all-courses", "get-course", "save-course", "update-course", "delete-course"])
  type        = "zip"
  source_file = "src/${each.key}.js"
  output_path = "${each.key}.zip"
}

module "lambdas" {
  for_each      = data.archive_file.zip
  source        = "./modules/lambda"
  
  function_name = each.key
  archive_path  = each.value.output_path
  role_arn      = aws_iam_role.lambda_exec.arn
  handler       = "${each.key}.handler"
  
  namespace     = "lpnu"
  stage         = "dev"
}

resource "aws_dynamodb_table_item" "init_author" {
  table_name = module.table_authors.table_name
  hash_key   = "id"

  item = <<ITEM
  {
    "id":   {"S": "1"},
    "name": {"S": "Myroslav Student"}
  }
  ITEM
}

resource "aws_dynamodb_table_item" "init_course" {
  table_name = module.table_courses.table_name
  hash_key   = "id"

  item = <<ITEM
{
  "id": {"S": "101"},
  "title": {"S": "Terraform Basics"},
  "authorId": {"S": "1"}
}
ITEM
}
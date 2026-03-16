resource "aws_lambda_function" "this" {
  filename         = var.archive_path
  function_name    = "${var.namespace}-${var.stage}-${var.function_name}"
  role             = var.role_arn
  handler          = "${var.function_name}.handler" # файл.функція
  source_code_hash = filebase64sha256(var.archive_path)
  runtime          = "nodejs18.x"
}
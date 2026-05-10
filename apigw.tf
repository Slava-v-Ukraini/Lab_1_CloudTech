resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.namespace}-${var.stage}-courses-api"
  description = "API для керування курсами та авторами (LPNU Lab2)"
}

# ------------------------
# РЕСУРС /authors 
resource "aws_api_gateway_resource" "authors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "authors"
}

resource "aws_api_gateway_method" "get_authors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_authors_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.authors.id
  http_method             = aws_api_gateway_method.get_authors.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambdas["get-all-authors"].invoke_arn
}

# -----------------------
# РЕСУРС /courses
resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "courses"
}

# GET /courses
resource "aws_api_gateway_method" "get_courses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_courses_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.get_courses.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambdas["get-all-courses"].invoke_arn
}

# POST /courses
resource "aws_api_gateway_method" "post_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.post_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambdas["save-course"].invoke_arn
}

# -----------------------
# РЕСУРС /courses/{id}
resource "aws_api_gateway_resource" "course_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.courses.id
  path_part   = "{id}"
}

# GET /courses/{id} з VTL 
resource "aws_api_gateway_method" "get_course_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_course_by_id_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.get_course_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambdas["get-course"].invoke_arn

  request_templates = {
    "application/json" = "{ \"id\": \"$input.params('id')\" }"
  }
}

resource "aws_api_gateway_method_response" "get_course_by_id_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.get_course_by_id.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "get_course_by_id_int_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.get_course_by_id.http_method
  status_code = aws_api_gateway_method_response.get_course_by_id_200.status_code
  depends_on  = [aws_api_gateway_integration.get_course_by_id_int]
}

# --------------------
# (Lambda Permissions)
resource "aws_lambda_permission" "allow_api" {
  for_each      = module.lambdas
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# ------------
# CORS
module "cors_authors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.authors.id
}

module "cors_courses" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.courses.id
}

module "cors_course_id" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.course_id.id
}

# ------

resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.get_authors_int,
    aws_api_gateway_integration.get_courses_int,
    aws_api_gateway_integration.post_course_int,
    aws_api_gateway_integration.get_course_by_id_int
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage
}

# Output для отримання URL твого API
output "api_url" {
  value = "${aws_api_gateway_stage.v1.invoke_url}/"
}
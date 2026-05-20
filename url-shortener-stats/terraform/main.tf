provider "aws" {

  region = var.region

  profile = "nueva-cuenta"
}

resource "aws_dynamodb_table" "url_visits" {

  name = var.visits_table

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "codigo"

  range_key = "timestamp"

  attribute {

    name = "codigo"

    type = "S"

  }

  attribute {

    name = "timestamp"

    type = "S"

  }

}


resource "aws_lambda_function" "stats" {

  function_name = var.lambda_name

  role = aws_iam_role.lambda_role.arn

  handler = "index.handler"

  runtime = "nodejs22.x"

  filename = "../lambda.zip"

  source_code_hash = filebase64sha256("../lambda.zip")

  environment {

    variables = {

      VISITS_TABLE = var.visits_table

    }

  }

}

resource "aws_apigatewayv2_api" "api" {

  name = "stats-api"

  protocol_type = "HTTP"

  cors_configuration {

    allow_origins = ["*"]

    allow_methods = [
      "GET",
      "OPTIONS"
    ]

    allow_headers = [
      "content-type"
    ]

    expose_headers = ["*"]

    max_age = 300

  }

}

resource "aws_apigatewayv2_integration" "integration" {

  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"

  integration_uri = aws_lambda_function.stats.invoke_arn

  payload_format_version = "2.0"

}

resource "aws_apigatewayv2_route" "route" {

  api_id = aws_apigatewayv2_api.api.id

  route_key = "GET /stats/{codigo}"

  target = "integrations/${aws_apigatewayv2_integration.integration.id}"

}

resource "aws_apigatewayv2_stage" "dev" {

  api_id = aws_apigatewayv2_api.api.id

  name = "$default"

  auto_deploy = true

}

resource "aws_lambda_permission" "api_gateway" {

  statement_id = "AllowExecution"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.stats.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"

}
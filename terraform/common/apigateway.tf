data "template_file" "openapi" {
  template = file("${path.module}/../../openapi/openapi.yml")
  vars = {
    cognito_user_pool_id                        = "${aws_cognito_user_pool_client.user_pool_client.user_pool_id}"
    cognito_client_id                           = "${aws_cognito_user_pool_client.user_pool_client.id}"
    arn_invoke_role                             = "${aws_iam_role.lambda_apigateway_exec_role.arn}"
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api"
  protocol_type = "HTTP"
  body          = data.template_file.openapi.rendered

  lifecycle {
    ignore_changes = [
      description,
      name,
      version
    ]
  }
}

resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "api"
  auto_deploy = true

  lifecycle {
    ignore_changes = [access_log_settings]
  }
}

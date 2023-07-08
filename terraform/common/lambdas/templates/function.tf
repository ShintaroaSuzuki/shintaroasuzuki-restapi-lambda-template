data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../../src/${var.function_name}"
  output_path = "lambda/${var.function_name}.zip"
}

resource "aws_lambda_function" "function" {
  function_name    = var.function_name
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  runtime          = var.runtime
  role             = var.lambda_exec_role
  architectures    = var.architectures
  memory_size      = var.memory_size
  timeout          = var.timeout
  layers           = var.layers
  environment {
    variables = var.environment
  }
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  depends_on = [
    aws_cloudwatch_log_group.cw_log_group
  ]
}

resource "aws_cloudwatch_log_group" "cw_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}

output "arn_function" {
  value = aws_lambda_function.function.arn
}

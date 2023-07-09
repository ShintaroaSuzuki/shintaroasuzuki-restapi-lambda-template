resource "aws_iam_role" "lambda_iam_role" {
  name                = "lambda_iam_role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# Policy
resource "aws_iam_role_policy" "lambda_access_policy" {
  name   = "lambda_access_policy"
  role   = aws_iam_role.lambda_iam_role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "dynamodb:*",
        "cognito-identity:*",
        "cognito-idp:*",
        "ses:SendEmail",
        "secretsmanager:GetSecretValue",
        "rds-db:connect",
        "sqs:*",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "lambda_apigateway_exec_role" {
  name = "lambda_apigateway_exec_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# Policy
resource "aws_iam_role_policy" "lambda_apigateway_exec_policy" {
  name   = "llambda_apigateway_exec_policy"
  role   = aws_iam_role.lambda_apigateway_exec_role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "*"
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "rds_proxy_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_proxy_role" {
  name               = "rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json
}

resource "aws_iam_role_policy" "rds_proxy_policy" {
  name   = "rds-proxy-policy"
  role   = aws_iam_role.rds_proxy_role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:*"
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "ec2_bastion_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_bastion_role" {
  name               = "EC2BastionRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_bastion_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_bastion_policy_attachment" {
  role       = aws_iam_role.ec2_bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_bastion" {
  name = "EC2BastionProfile"
  role = aws_iam_role.ec2_bastion_role.name
}

resource "aws_iam_role" "cognito_sms" {
    name = "cognito_sms"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Condition = {
                            StringEquals = {
                                "sts:ExternalId" = "${local.app_name}"
                            }
                        }
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "cognito-idp.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    inline_policy {
        name   = "cognito_sms_policy"
        policy = jsonencode(
            {
                Statement = [
                    {
                        Action   = [
                            "sns:publish",
                        ]
                        Effect   = "Allow"
                        Resource = [
                            "*",
                        ]
                    },
                ]
                Version   = "2012-10-17"
            }
        )
    }
    force_detach_policies = false
    max_session_duration  = 3600
    path                  = "/service-role/"
}

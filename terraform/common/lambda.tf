resource "aws_security_group" "vpc_lambda" {
  name        = "vpc-lambda"
  description = "vpc lambda security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "lambdas" {
  source           = "./lambdas"
  lambda_exec_role = aws_iam_role.lambda_iam_role.arn
  db_name          = aws_rds_cluster.sonawaru_app_db.database_name
  proxy_endpoint   = aws_db_proxy.rds_proxy.endpoint
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  security_group_ids = [
    aws_security_group.vpc_lambda.id
  ]
  client_id    = aws_cognito_user_pool_client.user_pool_client.id
  user_pool_id = aws_cognito_user_pool.user_pool.id
  domain                    = local.site_domain
}

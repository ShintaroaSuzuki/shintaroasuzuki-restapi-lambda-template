resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.env_name}-sonawaru-app-user-pool"

  admin_create_user_config {
    # ユーザーに自己サインアップを許可しないかどうか
    allow_admin_create_user_only = false
  }

  mfa_configuration = "ON"
  sms_authentication_message = " 認証コードは {####} です。"

  sms_configuration {
    external_id = "sonawaru"
    sns_caller_arn = aws_iam_role.cognito_sms.arn
    sns_region = "ap-northeast-1"
  }

  # 検証が必要な属性
  auto_verified_attributes = [
    "phone_number"
  ]
  # 属性更新時の設定
  user_attribute_update_settings = {
    attributes_require_verification_before_update = [
      "phone_number"
    ]
  }
  sms_verification_message = " 検証コードは {####} です。"

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "phone_number"
    required                 = true

    string_attribute_constraints {
      max_length = "20"
      min_length = "0"
    }
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                          = "${var.env_name}-sonawaru-app"
  user_pool_id                 = aws_cognito_user_pool.user_pool.id

  # OAuthを今回使用しないため設定しない
  allowed_oauth_flows                  = null
  allowed_oauth_flows_user_pool_client = false
  allowed_oauth_scopes                 = null
  callback_urls                        = null

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  logout_urls                   = null
  prevent_user_existence_errors = "ENABLED"

  # 更新トークンの期限
  refresh_token_validity       = 30
  supported_identity_providers = null

  # 属性の読み取り有無設定
  read_attributes = [
    "name",
    "phone_number",
    "phone_number_verified",
    "updated_at",
  ]

  # 属性の書き有無設定。
  write_attributes = [
    "name",
    "phone_number",
    "updated_at",
  ]
}

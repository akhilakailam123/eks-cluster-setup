resource "aws_secretsmanager_secret" "isms24-secrets" {
  name        = "isms24-secrets-${var.environment}"
  description = "RDS credentials stored securely"
  kms_key_id  = data.aws_kms_alias.secret_manager_key.id
}

resource "aws_secretsmanager_secret_version" "isms24-secrets_version" {
  secret_id = aws_secretsmanager_secret.isms24-secrets.id
  secret_string = jsonencode({
    username = ""
    password = ""
  })
}

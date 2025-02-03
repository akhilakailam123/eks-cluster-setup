data "aws_caller_identity" "this" {}

data "aws_kms_alias" "rds_kms_key" {
  name = "alias/aws/rds"
}

data "aws_kms_alias" "secret_manager_key" {
  name = "alias/aws/secretsmanager"
}

data "aws_kms_alias" "s3_kms_key" {
  name = "alias/aws/s3"
}

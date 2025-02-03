resource "aws_s3_bucket" "ecom_s3" {
  bucket = "ecom-data-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${var.environment}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_data_encryption" {
  bucket = aws_s3_bucket.ecom_s3.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.s3_kms_key.target_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

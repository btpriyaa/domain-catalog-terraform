# Root/managed storage for this domain's catalog — domain-owned so blast
# radius and billing stay isolated per domain.

resource "aws_s3_bucket" "uc_storage" {
  bucket = "${var.domain_name}-${var.environment}-uc-storage"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "uc_storage" {
  bucket = aws_s3_bucket.uc_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "uc_storage" {
  bucket                  = aws_s3_bucket.uc_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cross-account IAM role Databricks assumes to read/write the bucket.
# Verify the trusted principal ARN and external ID format against current
# Databricks docs for your region before applying.
resource "aws_iam_role" "uc_access" {
  name = "${var.domain_name}-${var.environment}-uc-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = { "sts:ExternalId" = var.databricks_account_id }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "uc_access" {
  name = "${var.domain_name}-${var.environment}-uc-access-policy"
  role = aws_iam_role.uc_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket", "s3:GetBucketLocation"]
      Resource = [aws_s3_bucket.uc_storage.arn, "${aws_s3_bucket.uc_storage.arn}/*"]
    }]
  })
}

resource "databricks_storage_credential" "this" {
  provider = databricks.workspace
  name     = "${var.domain_name}-${var.environment}-cred"

  aws_iam_role {
    role_arn = aws_iam_role.uc_access.arn
  }

  comment = "Storage credential for ${var.domain_name} catalog root storage"
}

resource "databricks_external_location" "this" {
  provider        = databricks.workspace
  name            = "${var.domain_name}-${var.environment}-root"
  url             = "s3://${aws_s3_bucket.uc_storage.bucket}/"
  credential_name = databricks_storage_credential.this.name
  comment         = "Root external location for ${var.domain_name} catalog"
}

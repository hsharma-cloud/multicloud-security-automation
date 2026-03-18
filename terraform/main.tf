provider "aws" {
  region = "us-east-1"
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "cloudtrail-secure-logstorage-hari-2026"

  tags = {
    Name        = "CloudTrail Log Storage"
    Environment = "Production"
    Purpose     = "Security Monitoring"
  }
}

# Enable versioning (best practice for logs)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access (security best practice)
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudTrail configuration
resource "aws_cloudtrail" "trail" {
  name                          = "security-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true

  depends_on = [
    aws_s3_bucket.cloudtrail_bucket
  ]
}

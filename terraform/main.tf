provider "aws" {
  region = "us-east-1"
}

# Unique suffix for S3 bucket
resource "random_id" "suffix" {
  byte_length = 4
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# S3 bucket (unique)
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "cloudtrail-secure-logstorage-hari-${random_id.suffix.hex}"

  tags = {
    Name        = "CloudTrail Log Storage"
    Environment = "Production"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudTrail bucket policy
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_bucket.arn
      },
      {
        Sid = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail (MANUAL UNIQUE NAME — FINAL FIX)
resource "aws_cloudtrail" "trail" {
  name                          = "security-trail-hari-final-001"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_policy
  ]
}

# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.main.id

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "cicd-ec2-instance"
  }
}

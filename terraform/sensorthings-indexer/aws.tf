# Note that we are in Oregon (us-west-2)
provider "aws" {
	profile = "default"
	region  = "us-west-2"
}

# We use this bucket for storing Schema.org documents generated by
# the Lambda function, as well as storing the Node.js code for the
# Lambda function.
# Public access via the web is enabled for supporting crawlers.
resource "aws_s3_bucket" "sta-schema-org-indexes" {
  bucket = "sta-schema-org-indexes"
  acl    = "public-read"

  cors_rule {
    allowed_headers = [
    "*",
    ]
    allowed_methods = [
    "GET",
    "PUT",
    "POST",
    "DELETE",
    ]
    allowed_origins = [
    "*",
    ]
    expose_headers  = []
    max_age_seconds = 0
  }

  versioning {
    enabled    = false
    mfa_delete = false
  }

  website {
    error_document = "error.html"
    index_document = "index.html"
  }
}

# Indexing happens once per day.
resource "aws_cloudwatch_event_rule" "daily" {
  description = "Runs every 24 hours."
  schedule_expression = "rate(1 day)"
}

# A role is needed to execute the Lambda.
resource "aws_iam_role" "lambda_sta_indexer" {
  name = "lambda_sta_indexer"

  assume_role_policy = <<EOF
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
EOF
}

# Apply `AWSLambdaBasicExecutionRole` to IAM role to allow access to
# running the Lambda and sending logs to CloudWatch.
resource "aws_iam_role_policy_attachment" "terraform_lambda_policy" {
  role       = "${aws_iam_role.lambda_sta_indexer.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# The AWS Lambda IAM role above needs to be modified to include an
# inline access policy for reading and writing to the S3 bucket.
resource "aws_iam_role_policy" "inline-sta-s3-bucket-rw" {
    name = "inline-sta-s3-bucket-rw"
    role = aws_iam_role.lambda_sta_indexer.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutAnalyticsConfiguration",
                "s3:GetObjectVersionTagging",
                "s3:CreateBucket",
                "s3:ReplicateObject",
                "s3:GetObjectAcl",
                "s3:GetBucketObjectLockConfiguration",
                "s3:DeleteBucketWebsite",
                "s3:PutLifecycleConfiguration",
                "s3:GetObjectVersionAcl",
                "s3:DeleteObject",
                "s3:GetBucketPolicyStatus",
                "s3:GetObjectRetention",
                "s3:GetBucketWebsite",
                "s3:PutReplicationConfiguration",
                "s3:PutObjectLegalHold",
                "s3:GetObjectLegalHold",
                "s3:GetBucketNotification",
                "s3:PutBucketCORS",
                "s3:GetReplicationConfiguration",
                "s3:ListMultipartUploadParts",
                "s3:PutObject",
                "s3:GetObject",
                "s3:PutBucketNotification",
                "s3:PutBucketLogging",
                "s3:GetAnalyticsConfiguration",
                "s3:PutBucketObjectLockConfiguration",
                "s3:GetObjectVersionForReplication",
                "s3:GetLifecycleConfiguration",
                "s3:GetInventoryConfiguration",
                "s3:GetBucketTagging",
                "s3:PutAccelerateConfiguration",
                "s3:DeleteObjectVersion",
                "s3:GetBucketLogging",
                "s3:ListBucketVersions",
                "s3:RestoreObject",
                "s3:ListBucket",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketPolicy",
                "s3:PutEncryptionConfiguration",
                "s3:GetEncryptionConfiguration",
                "s3:GetObjectVersionTorrent",
                "s3:AbortMultipartUpload",
                "s3:GetBucketRequestPayment",
                "s3:GetObjectTagging",
                "s3:GetMetricsConfiguration",
                "s3:DeleteBucket",
                "s3:PutBucketVersioning",
                "s3:GetBucketPublicAccessBlock",
                "s3:ListBucketMultipartUploads",
                "s3:PutMetricsConfiguration",
                "s3:GetBucketVersioning",
                "s3:GetBucketAcl",
                "s3:PutInventoryConfiguration",
                "s3:GetObjectTorrent",
                "s3:PutBucketWebsite",
                "s3:PutBucketRequestPayment",
                "s3:PutObjectRetention",
                "s3:GetBucketCORS",
                "s3:GetBucketLocation",
                "s3:ReplicateDelete",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::sta-schema-org-indexes",
                "arn:aws:s3:::sta-schema-org-indexes/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "s3:ListAccessPoints",
                "s3:ListJobs",
                "s3:CreateJob",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

#
# arctic-sensors
# 
resource "aws_lambda_function" "sta-index-arctic-sensors" {
  s3_bucket         = "sta-schema-org-indexes"
  s3_key            = "lambda.zip"
  source_code_hash  = "9DBmNW914K0DcszmUIZuFI6A2KYfQGSFSqgNmSsCiPI="
  function_name     = "sta-index-arctic-sensors"
  role              = aws_iam_role.lambda_sta_indexer.arn
  handler           = "index.handler"
  runtime           = "nodejs12.x"
  timeout           = "180"

  environment {
    variables = {
      S3_BUCKET = "sta-schema-org-indexes"
      S3_PATH   = "arctic-sensors.sensorup.com"
      S3_REGION = "us-west-2"
      STA_URL   = "https://arctic-sensors.sensorup.com/v1.0"
    }
  }
}

resource "aws_lambda_permission" "run-sta-indexer-arctic-sensors" {
  statement_id = "run-sta-indexer-arctic-sensors"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sta-index-arctic-sensors.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.daily.arn
}

resource "aws_cloudwatch_event_target" "sta-indexer-arctic-sensors" {
  target_id = "daily"
  rule      = aws_cloudwatch_event_rule.daily.name
  arn       = aws_lambda_function.sta-index-arctic-sensors.arn
}

#
# ucalgary-sandbox-01
# 
resource "aws_lambda_function" "sta-index-ucalgary-sandbox-01" {
  s3_bucket         = "sta-schema-org-indexes"
  s3_key            = "lambda.zip"
  source_code_hash  = "9DBmNW914K0DcszmUIZuFI6A2KYfQGSFSqgNmSsCiPI="
  function_name     = "sta-index-ucalgary-sandbox-01"
  role              = aws_iam_role.lambda_sta_indexer.arn
  handler           = "index.handler"
  runtime           = "nodejs12.x"
  timeout           = "180"

  environment {
    variables = {
      S3_BUCKET = "sta-schema-org-indexes"
      S3_PATH   = "ucalgary-sandbox-01.sensorup.com"
      S3_REGION = "us-west-2"
      STA_URL   = "https://ucalgary-sandbox-01.sensorup.com/v1.0"
    }
  }
}

resource "aws_lambda_permission" "run-sta-indexer-ucalgary-sandbox-01" {
  statement_id = "run-sta-indexer-ucalgary-sandbox-01"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sta-index-ucalgary-sandbox-01.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.daily.arn
}

resource "aws_cloudwatch_event_target" "sta-indexer-ucalgary-sandbox-01" {
  target_id = "daily"
  rule      = aws_cloudwatch_event_rule.daily.name
  arn       = aws_lambda_function.sta-index-ucalgary-sandbox-01.arn
}

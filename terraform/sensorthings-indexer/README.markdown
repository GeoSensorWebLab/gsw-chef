# Terraform: SensorThings Indexer

Terraform scripts to set up AWS with SensorThings API indexers on AWS Lambda. Will configure:

* S3 bucket `sta-schema-org-indexes`
    * for storing Node.js application for AWS Lambda
    * for storing JSON-LD documents from indexer
* CloudWatch event for running Lambda once per day
* AWS Lambda functions for each STA instance to be indexed

![Architecture Diagram](architecture_diagram.png)

## Instructions

Start by creating the AWS resources:

```
$ terraform apply
```

The run may fail due to the application not being uploaded to S3 yet. Package the Lambda application (in our case, the Node.js schema.org indexer) and upload to S3:

```
$ cd path/to/indexer
$ ./bin/lambda.sh
$ aws s3 cp lambda.zip s3://sta-schema-org-indexes/lambda.zip
```

Then re-run terraform:

```
$ terraform apply
```

## Updating the Lambda

If the source code used in the Lambda is updated, then it must be re-zipped and uploaded to Amazon S3. Then the `source_code_hash` in `aws.tf` must be updated, using the output from the following command:

```
$ openssl dgst -sha256 -binary lambda.zip| openssl enc -base64
```

After updating `aws.tf`, re-run `terraform apply` to force an update of the Lambda function with the latest version of the code.

## Adding the S3 Bucket Web Index

An `index.html` page has been included here for use as the index page in the S3 bucket, providing web users with a list of files in the bucket. Use the aws tool to upload it:

```
$ aws s3 cp index.html s3://sta-schema-org-indexes/index.html --acl public-read
```

It will then be available at [https://sta-schema-org-indexes.s3-us-west-2.amazonaws.com/index.html](https://sta-schema-org-indexes.s3-us-west-2.amazonaws.com/index.html).

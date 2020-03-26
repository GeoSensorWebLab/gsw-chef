# Terraform: SensorThings Indexer

Terraform scripts to set up AWS with SensorThings API indexers on AWS Lambda. Will configure:

* S3 bucket `sta-schema-org-indexes`
    * for storing Node.js application for AWS Lambda
    * for storing JSON-LD documents from indexer
* CloudWatch event for running Lambda once per day
* AWS Lambda functions for each STA instance to be indexed

## Instructions

Start by creating the AWS resources:

```
$ terraform apply
```

Next, package the Lambda application (in our case, the Node.js schema.org indexer) and upload to S3:

```
$ cd path/to/indexer
$ ./bin/lambda.sh
$ aws s3 cp lambda.zip s3://sta-schema-org-indexes/lambda.zip
```

TODO: Connect trigger to Lambda, test

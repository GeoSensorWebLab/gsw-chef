# Terraform Remote State

This set of Terraform files sets up an S3 bucket to store remote state for Terraform for GSW Lab resources. DynamoDB is used to store a "lock" to prevent multiple developers from updating at the same time.

## Setup

I highly recommend setting up [named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) for the AWS command line interface. Create a specific `gswlab` profile with the key credentials you use for the lab, as a way to separate them from other AWS accounts you may be using.

Once set up, Terraform providers should then be using `profile = "gswlab"` to ensure the correct credentials are being used. See `provider.tf` for an example.

## First Run

On first run, the bucket and DynamoDB table do not already exist. Delete the local terraform configuration directory (`.terraform`) and comment out `terraform.tf` to use the local state for Terraform. Then run `terraform apply` to create the new bucket and tables.

After the bucket has been created, uncomment `terraform.tf` and re-run `terraform init` to sync the local state to the remote state in S3. This will also enable locking for Terraform runs.

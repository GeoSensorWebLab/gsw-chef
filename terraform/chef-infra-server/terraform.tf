terraform {
 backend "s3" {
   encrypt        = true
   bucket         = "gswlab-terraform-state"
   dynamodb_table = "gswlab-terraform-state-lock-dynamo"
   region         = "us-west-2"
   key            = "production/chef-infra-server"
 }
}

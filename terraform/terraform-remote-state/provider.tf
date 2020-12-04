# Most resources will be in Oregon (US-West-2)
provider "aws" {
  allowed_account_ids = ["546905020646"]
  profile             = "gswlab"
  region              = "us-west-2"
  version             = "~> 2.0"
}

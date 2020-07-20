# Note that we are in Oregon (us-west-2)
provider "aws" {
  profile = "default"
  region  = "us-west-2"
  version = "~> 2.0"
}
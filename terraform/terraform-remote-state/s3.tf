# Bucket will store remote state
resource "aws_s3_bucket" "gswlab-terraform-state" {
    bucket = "gswlab-terraform-state"
 
    versioning {
      enabled = true
    }
 
    lifecycle {
      prevent_destroy = true
    }
 
    tags = {
      "Name" = "S3 Remote State Store for Terraform"
    }      
}

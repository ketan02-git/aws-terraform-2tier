terraform {
  backend "s3" {
    bucket         = "ketan-terraform-state-bucket"
    key            = "secure-2tier/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "dev/terraform.tfstate"
    region        = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

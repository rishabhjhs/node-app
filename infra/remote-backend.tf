terraform {
  backend "s3" {
    bucket         = "app-bucket-121"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "app-lock"
    encrypt        = true
    profile        = "default"
  }
}

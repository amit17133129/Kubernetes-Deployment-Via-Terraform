terraform {
  backend "s3" {
    bucket = "terraform-xxxxx-backend"
    key    = "k8s/tf/terraform.tfstate"
    region = "us-east-1"
  }
}
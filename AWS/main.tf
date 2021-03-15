
provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "base-of-product-roolrd"
    key    = "cluster/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_ecs_cluster" "base_of_product" {
  name = "base-of-product"
}

resource "aws_ecr_repository" "base-of-product" {
  name = "base-of-product"
}

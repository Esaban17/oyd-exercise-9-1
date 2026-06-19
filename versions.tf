terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider — deploys to the region specified by var.aws_region
provider "aws" {
  region = var.aws_region
}

# Alias required for EstimatedCharges alarms: AWS Billing metrics are
# only published in us-east-1 regardless of the default region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  region = var.region
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"] 

  default_tags {
    tags = {
      created_by = "terraform"
      workspace = terraform.workspace
    }
  }
}

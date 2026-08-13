provider "aws" {
  region = var.aws_region
}

provider "databricks" {
  alias = "workspace"
  host  = var.databricks_workspace_url
  # Auth via DATABRICKS_CLIENT_ID / DATABRICKS_CLIENT_SECRET env vars.
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
}

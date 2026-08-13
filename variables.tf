variable "databricks_workspace_url" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "metastore_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "catalog_admin_group" {
  description = "Account-level group that becomes catalog owner"
  type        = string
}

# Fixed at bronze/silver/gold to match the medallion layers the access
# matrix is defined against. Add layers here only if the access-control
# module's schema_grants map is updated to match.
variable "schemas" {
  type    = list(string)
  default = ["bronze", "silver", "gold"]
}

variable "sql_warehouse_size" {
  type    = string
  default = "Small"
}

variable "sql_warehouse_max_clusters" {
  type    = number
  default = 3
}

variable "tags" {
  type    = map(string)
  default = {}
}

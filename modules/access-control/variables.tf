# -----------------------------------------------------------------------
# This module encodes the persona access matrix. It is owned by the
# domain admin team — schema/storage plumbing (the calling repo) shouldn't
# need to change when persona privileges change, and vice versa.
# -----------------------------------------------------------------------

variable "catalog_name" {
  description = "Name of the catalog this matrix applies to"
  type        = string
}

variable "schema_ids" {
  description = "Map of schema key -> databricks_schema resource id. MUST contain exactly the keys 'bronze', 'silver', 'gold'."
  type        = map(string)

  validation {
    condition     = alltrue([for k in ["bronze", "silver", "gold"] : contains(keys(var.schema_ids), k)])
    error_message = "schema_ids must contain 'bronze', 'silver', and 'gold' keys."
  }
}

variable "domain_admins_group" {
  type = string
}

variable "data_engineers_group" {
  type = string
}

variable "data_scientists_group" {
  type = string
}

variable "data_analysts_group" {
  type = string
}

variable "business_analysts_group" {
  type = string
}

variable "sql_warehouse_id" {
  description = "ID of the serverless SQL warehouse to grant persona-based usage permissions on"
  type        = string
}

variable "secret_scope_name" {
  description = "Name of the domain secret scope to apply persona-based ACLs to"
  type        = string
}

data "databricks_metastore" "this" {
  provider     = databricks.workspace
  metastore_id = var.metastore_id
}

data "databricks_group" "catalog_admins" {
  provider     = databricks.account
  display_name = "${var.domain_name}-catalog-admins"
}

data "databricks_group" "data_engineers" {
  provider     = databricks.account
  display_name = "${var.domain_name}-data-engineers"
}

data "databricks_group" "data_scientists" {
  provider     = databricks.account
  display_name = "${var.domain_name}-data-scientists"
}

data "databricks_group" "data_analysts" {
  provider     = databricks.account
  display_name = "${var.domain_name}-data-analysts"
}

data "databricks_group" "business_analysts" {
  provider     = databricks.account
  display_name = "${var.domain_name}-business-analysts"
}

# workspace_access = full notebook/repo/workspace UI access
# databricks_sql_access = SQL editor / dashboards / serverless SQL warehouse access
#
# Analysts and business analysts get databricks_sql_access only — this is
# what limits them to "SQL editor / dashboards" per the access matrix,
# without granting full notebook/Repos access.

resource "databricks_entitlements" "domain_admins" {
  group_id               = data.databricks_group.domain_admins_lookup.id
  workspace_access        = true
  databricks_sql_access    = true
}

resource "databricks_entitlements" "data_engineers" {
  group_id               = data.databricks_group.data_engineers_lookup.id
  workspace_access        = true
  databricks_sql_access    = true
}

resource "databricks_entitlements" "data_scientists" {
  group_id               = data.databricks_group.data_scientists_lookup.id
  workspace_access        = true
  databricks_sql_access    = true
}

resource "databricks_entitlements" "data_analysts" {
  group_id               = data.databricks_group.data_analysts_lookup.id
  workspace_access        = false
  databricks_sql_access    = true
}

resource "databricks_entitlements" "business_analysts" {
  group_id               = data.databricks_group.business_analysts_lookup.id
  workspace_access        = false
  databricks_sql_access    = true
}

# databricks_entitlements keys off group_id, not display_name, so the
# module re-resolves ids from the display names it was given. These are
# read-only lookups — the module never creates or deletes a group.
data "databricks_group" "domain_admins_lookup" {
  display_name = var.domain_admins_group
}

data "databricks_group" "data_engineers_lookup" {
  display_name = var.data_engineers_group
}

data "databricks_group" "data_scientists_lookup" {
  display_name = var.data_scientists_group
}

data "databricks_group" "data_analysts_lookup" {
  display_name = var.data_analysts_group
}

data "databricks_group" "business_analysts_lookup" {
  display_name = var.business_analysts_group
}

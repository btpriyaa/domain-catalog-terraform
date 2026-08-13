# -----------------------------------------------------------------------
# The actual persona access matrix lives in modules/access-control,
# owned by the domain admin team. This file just creates the one
# object (the secret scope) the module needs a name for, and wires
# everything together.
# -----------------------------------------------------------------------

resource "databricks_secret_scope" "domain" {
  provider = databricks.workspace
  name     = "${var.domain_name}-secrets"
}

module "access_control" {
  source = "./modules/access-control"

  providers = {
    databricks = databricks.workspace
  }

  catalog_name = databricks_catalog.domain.name

  schema_ids = {
    bronze = databricks_schema.this["bronze"].id
    silver = databricks_schema.this["silver"].id
    gold   = databricks_schema.this["gold"].id
  }

  domain_admins_group     = data.databricks_group.catalog_admins.display_name
  data_engineers_group    = data.databricks_group.data_engineers.display_name
  data_scientists_group   = data.databricks_group.data_scientists.display_name
  data_analysts_group     = data.databricks_group.data_analysts.display_name
  business_analysts_group = data.databricks_group.business_analysts.display_name

  sql_warehouse_id  = databricks_sql_endpoint.domain_warehouse.id
  secret_scope_name = databricks_secret_scope.domain.name
}

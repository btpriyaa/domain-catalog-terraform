# Serverless compute only — no databricks_cluster / databricks_cluster_policy
# resources in this repo. The shared warehouse is created here; who can use
# vs. manage it is decided by the access-control module (persona logic
# lives there, not here).

resource "databricks_sql_endpoint" "domain_warehouse" {
  provider                  = databricks.workspace
  name                       = "${var.domain_name}-sql-warehouse"
  cluster_size               = var.sql_warehouse_size
  auto_stop_mins             = 30
  min_num_clusters           = 1
  max_num_clusters           = var.sql_warehouse_max_clusters
  enable_serverless_compute  = true
  warehouse_type              = "PRO"

  tags {
    custom_tags {
      key   = "domain"
      value = var.domain_name
    }
    custom_tags {
      key   = "environment"
      value = var.environment
    }
  }
}

# NOTE: self-service creation of *additional* SQL warehouses or serverless
# jobs (as opposed to using this shared one) is restricted per the access
# matrix to Domain Admin + Data Engineer only. That restriction is enforced
# via the workspace admin console's "Warehouse creation" / "Job creation"
# default permission setting — the Databricks Terraform provider does not
# currently expose a resource for that workspace-wide default, so it's a
# one-time manual step. See README "Manual one-time steps".

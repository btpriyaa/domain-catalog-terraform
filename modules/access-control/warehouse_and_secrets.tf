# --- Serverless SQL warehouse usage (only warehouse type in this repo) ---
# Everyone can USE the shared warehouse; only admins + engineers can MANAGE
# it (restart, resize, edit). Self-service creation of *additional* ad hoc
# warehouses is restricted separately at the workspace admin console level
# (see README) — the provider has no dedicated "who can create new
# warehouses" resource, so that one setting is a manual, one-time step.

resource "databricks_permissions" "sql_warehouse" {
  sql_endpoint_id = var.sql_warehouse_id

  access_control {
    group_name       = var.domain_admins_group
    permission_level = "CAN_MANAGE"
  }
  access_control {
    group_name       = var.data_engineers_group
    permission_level = "CAN_MANAGE"
  }
  access_control {
    group_name       = var.data_scientists_group
    permission_level = "CAN_USE"
  }
  access_control {
    group_name       = var.data_analysts_group
    permission_level = "CAN_USE"
  }
  access_control {
    group_name       = var.business_analysts_group
    permission_level = "CAN_USE"
  }
}

# --- Secrets: admin manages, engineers write within their own domain,
# everyone else has no access — per "Manage secret scopes" row in the
# access matrix. ---

resource "databricks_secret_acl" "domain_admins" {
  scope      = var.secret_scope_name
  principal  = var.domain_admins_group
  permission = "MANAGE"
}

resource "databricks_secret_acl" "data_engineers" {
  scope      = var.secret_scope_name
  principal  = var.data_engineers_group
  permission = "WRITE"
}

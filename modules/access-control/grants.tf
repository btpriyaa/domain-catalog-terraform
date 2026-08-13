locals {
  # --- Catalog-level privileges per persona ---
  catalog_grants = {
    (var.domain_admins_group)     = ["ALL_PRIVILEGES"]
    (var.data_engineers_group)    = ["USE_CATALOG", "CREATE_SCHEMA", "CREATE_FUNCTION", "CREATE_VIEW", "EXECUTE"]
    (var.data_scientists_group)   = ["USE_CATALOG", "CREATE_FUNCTION", "CREATE_VIEW", "EXECUTE"]
    (var.data_analysts_group)     = ["USE_CATALOG", "EXECUTE"]
    (var.business_analysts_group) = ["USE_CATALOG"]
  }

  # --- Schema-level privileges per persona, per layer ---
  # bronze: engineers create/write, scientists read only, analysts/BAs excluded.
  # silver: engineers create/write, scientists read, analysts read, BAs excluded.
  # gold:   engineers + scientists create/write (scientists' own ML/gold
  #         objects — enforced naturally: Databricks makes the creator the
  #         owner), analysts read + create views, BAs read + gold-scoped execute.
  schema_grants = {
    bronze = {
      (var.data_engineers_group)  = ["CREATE_TABLE", "MODIFY", "SELECT"]
      (var.data_scientists_group) = ["SELECT"]
    }
    silver = {
      (var.data_engineers_group)  = ["CREATE_TABLE", "MODIFY", "SELECT"]
      (var.data_scientists_group) = ["SELECT"]
      (var.data_analysts_group)   = ["SELECT"]
    }
    gold = {
      (var.data_engineers_group)    = ["CREATE_TABLE", "MODIFY", "SELECT"]
      (var.data_scientists_group)   = ["CREATE_TABLE", "MODIFY", "SELECT"]
      (var.data_analysts_group)     = ["SELECT", "CREATE_VIEW"]
      (var.business_analysts_group) = ["SELECT", "EXECUTE"]
    }
  }
}

resource "databricks_grants" "catalog" {
  catalog = var.catalog_name

  dynamic "grant" {
    for_each = local.catalog_grants
    content {
      principal  = grant.key
      privileges = grant.value
    }
  }
}

resource "databricks_grants" "schema" {
  for_each = var.schema_ids
  schema   = each.value

  dynamic "grant" {
    for_each = lookup(local.schema_grants, each.key, {})
    content {
      principal  = grant.key
      privileges = grant.value
    }
  }
}

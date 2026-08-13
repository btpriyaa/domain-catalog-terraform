resource "databricks_schema" "this" {
  for_each     = toset(var.schemas)
  provider     = databricks.workspace
  catalog_name = databricks_catalog.domain.name
  name         = each.value
  comment      = "Managed by domain terraform — ${each.value} layer"

  properties = merge(var.tags, {
    domain      = var.domain_name
    environment = var.environment
    layer       = each.value
  })
}

resource "databricks_volume" "landing" {
  provider     = databricks.workspace
  name         = "landing"
  catalog_name = databricks_catalog.domain.name
  schema_name  = databricks_schema.this["bronze"].name
  volume_type  = "MANAGED"
  comment      = "Landing zone for raw file ingestion"

  depends_on = [databricks_schema.this]
}

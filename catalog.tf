# Requires the identity running Terraform to already hold CREATE CATALOG on
# the metastore — granted once, out of band, by the metastore admin (see
# README). Terraform manages the catalog's full lifecycle from here on, but
# can't grant itself that first bootstrap privilege.

resource "databricks_catalog" "domain" {
  provider     = databricks.workspace
  metastore_id = data.databricks_metastore.this.id
  name         = "${var.domain_name}_${var.environment}"
  comment      = "Domain catalog for ${var.domain_name}, owned by domain team"
  owner        = var.catalog_admin_group
  storage_root = "${databricks_external_location.this.url}catalog/"

  depends_on = [databricks_external_location.this]
}

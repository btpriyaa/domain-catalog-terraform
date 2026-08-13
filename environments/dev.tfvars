databricks_workspace_url = "https://dbc-xxxxxxx-dev.cloud.databricks.com"
databricks_account_id    = "00000000-0000-0000-0000-000000000000"
metastore_id             = "11111111-1111-1111-1111-111111111111"
aws_region                = "us-east-1"

domain_name = "payments"
environment = "dev"

catalog_admin_group = "payments-catalog-admins"

sql_warehouse_size         = "Small"
sql_warehouse_max_clusters = 2

tags = {
  cost_center = "payments-domain"
  owner       = "payments-platform-team"
}

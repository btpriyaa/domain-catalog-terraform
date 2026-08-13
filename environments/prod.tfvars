databricks_workspace_url = "https://dbc-xxxxxxx-prod.cloud.databricks.com"
databricks_account_id    = "00000000-0000-0000-0000-000000000000"
metastore_id             = "11111111-1111-1111-1111-111111111111"
aws_region                = "us-east-1"

domain_name = "payments"
environment = "prod"

catalog_admin_group = "payments-catalog-admins"

sql_warehouse_size         = "Medium"
sql_warehouse_max_clusters = 4

tags = {
  cost_center = "payments-domain"
  owner       = "payments-platform-team"
}

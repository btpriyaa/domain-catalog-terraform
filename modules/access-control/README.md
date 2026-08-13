# modules/access-control

Owned and maintained by the **domain admin team**. This module is the only
place persona privileges are defined — changing what a Data Scientist can
do never requires touching `catalog.tf`, `main.tf`, or `storage.tf`.

## Source matrix

| Capability | Domain Admin | Data Engineer | Data Scientist | Data Analyst | Business Analyst |
|---|---|---|---|---|---|
| Create / drop catalog | Y | N | N | N | N |
| CREATE_SCHEMA (bronze/silver) | Y | Y (own domain) | N | N | N |
| CREATE_TABLE bronze/silver | Y | Y | N | N | N |
| CREATE_TABLE / MODIFY gold | Y | Y | Y (own ML/gold objects) | N | N |
| SELECT bronze | Y | Y | Y | N | N |
| SELECT silver | Y | Y | Y | Y | N |
| SELECT gold | Y | Y | Y | Y | Y |
| CREATE_FUNCTION | Y | Y | Y | N | N |
| CREATE_VIEW | Y | Y | Y | Y (gold) | N |
| EXECUTE (functions / registered models) | Y | Y | Y | Y | Y (gold-scoped) |
| Manage grants on own catalog | Y | N (PR only) | N | N | N |
| Use Serverless SQL Warehouse | Y | Y | Y | Y | Y |
| Create Serverless SQL Warehouse | Y | Y | N | N | N |
| Create / own Serverless Jobs | Y | Y | Y (own jobs) | N | N |
| Notebooks / Repos (Git folders) | Y | Y | Y | limited (SQL editor) | limited (SQL editor/dashboards) |
| Manage secret scopes | Y | Y (own domain) | N | N | N |
| Workspace admin console | Y | N | N | N | N |
| Audit logs / billing | Y | N | N | N | N |
| Network / IP access lists | Y | N | N | N | N |

Catalog/drop-catalog, workspace admin console, audit logs/billing, and
network/IP access lists are **not** modeled here — they're central,
account-level capabilities this repo never touches (see root README).
"Create Serverless SQL Warehouse" and "Create/own Serverless Jobs" (the
self-service creation, not usage, of new objects) are enforced via a
workspace admin console setting, not a Terraform resource — see root
README's manual-steps section.

## Inputs

| Variable | Purpose |
|---|---|
| `catalog_name` | Catalog to apply catalog-level grants to |
| `schema_ids` | Map with keys `bronze`, `silver`, `gold` → schema resource ids |
| `domain_admins_group`, `data_engineers_group`, `data_scientists_group`, `data_analysts_group`, `business_analysts_group` | Group display names |
| `sql_warehouse_id` | The shared serverless warehouse to set usage permissions on |
| `secret_scope_name` | Domain secret scope to set persona ACLs on |

## What this module creates

- `databricks_grants` — catalog-level and schema-level (`grants.tf`)
- `databricks_entitlements` — workspace vs. SQL-only access per persona (`entitlements.tf`)
- `databricks_permissions` on the SQL warehouse (`warehouse_and_secrets.tf`)
- `databricks_secret_acl` for the domain secret scope (`warehouse_and_secrets.tf`)

## What this module never creates

Groups, users, service principals, catalogs, schemas, the warehouse
itself, workspaces, or anything account-level. It only reads pre-existing
groups (by display name) and grants privileges to them.

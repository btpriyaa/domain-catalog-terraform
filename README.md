# Domain Team – Databricks Terraform (serverless-only, modular access control)

Provisions everything the domain team owns inside an already-existing
Databricks workspace, including the catalog. Serverless compute only — no
`databricks_cluster` or `databricks_cluster_policy` resources anywhere.
Persona access control is a standalone module owned by the domain admin
team.

## Ownership boundary

| Object | Status | Managed here? |
|---|---|---|
| AWS VPC / subnets / NCC / PrivateLink | Already exists, out of band | ❌ |
| Databricks workspace | Already exists | ❌ referenced by URL only |
| Unity Catalog metastore | Already exists, workspace already assigned | ❌ referenced by ID only |
| Account-level groups (SCIM) | Already exists, IdP-managed | ❌ read-only lookups only |
| Storage credential, external location | Domain-owned | ✅ `storage.tf` |
| Catalog | Domain-owned | ✅ `catalog.tf` |
| Schemas (bronze/silver/gold), volumes | Domain-owned | ✅ `main.tf` |
| Serverless SQL warehouse | Domain-owned | ✅ `compute.tf` |
| **Persona access matrix** (grants, entitlements, warehouse/secret permissions) | **Domain admin team** | ✅ `modules/access-control/` |

No `databricks_mws_*`, no `databricks_metastore` resource, no
`databricks_metastore_assignment`, no `databricks_group`/`user`/
`service_principal` resources anywhere in this repo.

## Why the access matrix is its own module

The persona table (who can SELECT gold, who can create a schema, who gets
full workspace access vs. SQL-editor-only) changes on a different cadence
and by a different owner than the schema/storage plumbing. Splitting it
out means:
- The domain admin team can PR `modules/access-control/grants.tf` without
  touching catalog/storage code, and vice versa
- The matrix is testable and reviewable as one self-contained unit
- The same module could be reused for a second domain catalog by passing
  different group names, without duplicating grant logic

## How it fits into the repo

```
domain-catalog-terraform/
├── ... (storage.tf, catalog.tf, main.tf, compute.tf — plumbing)
├── access.tf                        # creates the secret scope, then calls the module
└── modules/
    └── access-control/               # <-- domain admin team owns this folder
        ├── README.md                 # the access matrix, human-readable
        ├── variables.tf
        ├── grants.tf                 # catalog + schema UC grants
        ├── entitlements.tf           # workspace vs. SQL-only access per persona
        ├── warehouse_and_secrets.tf  # warehouse usage + secret ACLs per persona
        └── outputs.tf
```

`access.tf` in the root is a thin caller:

```hcl
module "access_control" {
  source = "./modules/access-control"
  providers = { databricks = databricks.workspace }

  catalog_name = databricks_catalog.domain.name
  schema_ids   = { bronze = ..., silver = ..., gold = ... }

  domain_admins_group     = data.databricks_group.catalog_admins.display_name
  data_engineers_group    = data.databricks_group.data_engineers.display_name
  data_scientists_group   = data.databricks_group.data_scientists.display_name
  data_analysts_group     = data.databricks_group.data_analysts.display_name
  business_analysts_group = data.databricks_group.business_analysts.display_name

  sql_warehouse_id  = databricks_sql_endpoint.domain_warehouse.id
  secret_scope_name = databricks_secret_scope.domain.name
}
```

If the domain admin team later wants full independence — their own PR
review path, their own CI stage, their own versioning — the same folder
can be pulled out into its own git repo and referenced via a `git::`
source URL instead of `./modules/access-control`, with no change to the
module's internals.

## Serverless-only compute

`compute.tf` creates exactly one resource: a serverless
`databricks_sql_endpoint`. There is no cluster policy and no all-purpose
cluster resource in this repo. Usage permission on that shared warehouse
is set by the access-control module, matching the persona table (everyone
can *use* it; only Domain Admin + Data Engineer can *manage* it).

## One-time prerequisites (not managed by Terraform)

1. Metastore admin grants `CREATE CATALOG` on the metastore to the
   domain-admin group:
   ```sql
   GRANT CREATE CATALOG ON METASTORE <metastore_id> TO `<domain>-catalog-admins`;
   ```
2. Workspace admin restricts self-service creation of new SQL warehouses
   and jobs to Domain Admin + Data Engineer, via the workspace admin
   console's default-permission setting (not yet a Terraform resource in
   the provider).

## Usage

```bash
terraform init  -backend-config=environments/dev.backend.hcl
terraform plan  -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

See `diagrams/ARCHITECTURE.md` for the updated flow, and
`ACCESS_MATRIX.md` / `modules/access-control/README.md` for the full
persona table.

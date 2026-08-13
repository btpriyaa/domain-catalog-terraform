# Access Matrix — Domain Workspace & Catalog

The full matrix and its Terraform implementation live in
[`modules/access-control/README.md`](modules/access-control/README.md) —
owned by the domain admin team. This file is a short pointer plus the two
things that live outside the module.

## Summary (see the module for the full table)

| Persona | Notebooks/Repos | SQL access | Catalog role |
|---|---|---|---|
| Domain Admin | Full | Full | Owner (ALL_PRIVILEGES) |
| Data Engineer | Full | Full | CREATE_SCHEMA, write bronze/silver/gold |
| Data Scientist | Full | Full | Write gold (own objects), read bronze/silver |
| Data Analyst | SQL editor only | Full | Read silver/gold, CREATE_VIEW on gold |
| Business Analyst | SQL editor/dashboards only | Full | Read + EXECUTE on gold only |

## Not modeled in this repo (account/central scope)

- Create/drop catalog itself is Domain-Admin-only and happens via
  `catalog.tf`, not persona grants
- Workspace admin console, audit logs/billing, network/IP access lists —
  central/account capabilities, out of scope everywhere in this repo

## Manual one-time steps (not expressible as Terraform resources today)

1. Metastore admin grants `CREATE CATALOG` on the metastore to the
   domain-admin group (see root README)
2. Workspace admin restricts **self-service creation** of new SQL
   warehouses and jobs to Domain Admin + Data Engineer only, via the
   workspace admin console's default-permission setting — the Terraform
   provider doesn't yet expose this as a resource. Everyone still gets
   *usage* of the shared serverless warehouse via `databricks_permissions`
   in the module.

## Change process

Any change to persona privileges is a PR against
`modules/access-control/grants.tf` / `entitlements.tf` — reviewed and
merged by the domain admin team, never applied via the Databricks UI.

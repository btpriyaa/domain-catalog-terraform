# Diagrams

## 1. Repo structure and module boundary

```mermaid
flowchart TD
    subgraph ROOT["Root repo — Domain Team (plumbing)"]
        STOR["storage.tf<br/>S3 + storage credential"]
        CAT["catalog.tf<br/>databricks_catalog"]
        SCH["main.tf<br/>schemas: bronze/silver/gold"]
        COMP["compute.tf<br/>serverless SQL warehouse"]
        SEC["access.tf<br/>secret scope + module call"]
        STOR --> CAT --> SCH
        SCH --> SEC
        COMP --> SEC
    end

    subgraph MOD["modules/access-control — Domain ADMIN Team"]
        GR["grants.tf<br/>catalog + schema UC grants"]
        ENT["entitlements.tf<br/>workspace vs SQL-only access"]
        WH["warehouse_and_secrets.tf<br/>warehouse + secret permissions"]
    end

    SEC -->|"module call, passes catalog/schema/group refs"| MOD
```

## 2. Persona access flow (5 personas, medallion layers)

```mermaid
flowchart LR
    subgraph Personas
        ADM["Domain Admin"]
        DE["Data Engineer"]
        DS["Data Scientist"]
        DA["Data Analyst"]
        BA["Business Analyst"]
    end

    subgraph Bronze["bronze schema"]
        B1["CREATE_TABLE/MODIFY: DE<br/>SELECT: DE, DS"]
    end
    subgraph Silver["silver schema"]
        S1["CREATE_TABLE/MODIFY: DE<br/>SELECT: DE, DS, DA"]
    end
    subgraph Gold["gold schema"]
        G1["CREATE_TABLE/MODIFY: DE, DS (own objects)<br/>SELECT: DE, DS, DA, BA<br/>CREATE_VIEW: DA<br/>EXECUTE: DA, BA (gold-scoped)"]
    end

    ADM -->|"ALL_PRIVILEGES on catalog"| Bronze
    ADM --> Silver
    ADM --> Gold
    DE --> Bronze
    DE --> Silver
    DE --> Gold
    DS --> Bronze
    DS --> Silver
    DS --> Gold
    DA --> Silver
    DA --> Gold
    BA --> Gold
```

## 3. Entitlements — workspace vs. SQL-only access

```mermaid
flowchart TD
    ADM["Domain Admin<br/>workspace_access=true, sql_access=true"] --> FULL["Full workspace:<br/>notebooks, Repos, SQL editor"]
    DE["Data Engineer<br/>workspace_access=true, sql_access=true"] --> FULL
    DS["Data Scientist<br/>workspace_access=true, sql_access=true"] --> FULL

    DA["Data Analyst<br/>workspace_access=false, sql_access=true"] --> SQLONLY["SQL editor / dashboards only<br/>(no notebooks/Repos)"]
    BA["Business Analyst<br/>workspace_access=false, sql_access=true"] --> SQLONLY
```

## 4. Serverless-only compute

```mermaid
flowchart LR
    WH["databricks_sql_endpoint<br/>enable_serverless_compute = true<br/>(compute.tf)"]
    PERM["databricks_permissions<br/>(access-control module)"]
    WH --> PERM

    PERM -->|"CAN_MANAGE"| ADM["Domain Admin"]
    PERM -->|"CAN_MANAGE"| DE["Data Engineer"]
    PERM -->|"CAN_USE"| DS["Data Scientist"]
    PERM -->|"CAN_USE"| DA["Data Analyst"]
    PERM -->|"CAN_USE"| BA["Business Analyst"]

    NOTE["No databricks_cluster or<br/>databricks_cluster_policy resources<br/>exist in this repo"]
```

## 5. One-time out-of-band steps vs. Terraform-managed

```mermaid
flowchart LR
    subgraph OOB["Out-of-band, done once, NOT in Terraform"]
        M1["Metastore admin grants<br/>CREATE CATALOG to domain-admin-group"]
        M2["Workspace admin restricts<br/>self-service warehouse/job creation<br/>to Admin + Data Engineer"]
    end

    subgraph TF["Terraform-managed"]
        T1["storage credential"] --> T2["external location"] --> T3["catalog"] --> T4["schemas"] --> T5["access-control module<br/>(grants, entitlements, warehouse/secret perms)"]
    end

    OOB --> T3
    OOB --> T5
```

## 6. CI/CD pipeline

```mermaid
flowchart LR
    DEV["PR against root repo<br/>OR modules/access-control"] --> PLAN["CI: terraform plan"]
    PLAN --> REVIEW{"Owning team reviews:<br/>domain team for plumbing,<br/>domain admin team for access-control"}
    REVIEW -- No --> DEV
    REVIEW -- Yes --> MERGE["Merge to main"]
    MERGE --> APPLYDEV["CD: apply to dev"]
    APPLYDEV --> APPLYSTG["CD: apply to staging (manual gate)"]
    APPLYSTG --> APPLYPROD["CD: apply to prod (manual gate + change ticket)"]
```

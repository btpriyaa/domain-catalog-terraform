bucket         = "domain-payments-tfstate-staging"
key            = "databricks/domain/staging/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "domain-payments-tflock-staging"
encrypt        = true

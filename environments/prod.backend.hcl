bucket         = "domain-payments-tfstate-prod"
key            = "databricks/domain/prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "domain-payments-tflock-prod"
encrypt        = true

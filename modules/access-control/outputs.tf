output "personas" {
  description = "Persona group names this matrix was applied to, for reference/debugging"
  value = {
    domain_admins     = var.domain_admins_group
    data_engineers    = var.data_engineers_group
    data_scientists   = var.data_scientists_group
    data_analysts     = var.data_analysts_group
    business_analysts = var.business_analysts_group
  }
}

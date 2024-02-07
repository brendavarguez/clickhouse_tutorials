locals {
  # your cluster's namespace where all CH
  # services will be running
  namespace = "stg"
}

output "pass" {
  value     = random_password.ci_password.result
  sensitive = true
}

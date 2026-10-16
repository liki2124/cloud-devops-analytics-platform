terraform {
  required_version = ">= 1.5.0"
}

locals {
  project_name = "cloud-devops-analytics-platform"

  services = {
    api = {
      port    = 8000
      purpose = "Application API"
    }
    prometheus = {
      port    = 9090
      purpose = "Metrics collection"
    }
    grafana = {
      port    = 3000
      purpose = "Monitoring dashboards"
    }
    cadvisor = {
      port    = 8080
      purpose = "Container metrics"
    }
  }
}

output "project_name" {
  description = "Name of the Cloud and DevOps Analytics Platform."
  value       = local.project_name
}

output "local_service_endpoints" {
  description = "Local endpoints for the existing Docker Compose services."
  value = {
    for service, config in local.services :
    service => "http://localhost:${config.port}"
  }
}

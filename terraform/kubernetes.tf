terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "C:/Users/likit/.kube/config"
  config_context = "kind-devops-platform"
}

data "kubernetes_namespace_v1" "existing" {
  metadata {
    name = "devops-platform"
  }
}

data "kubernetes_service_v1" "analytics_api" {
  metadata {
    name      = "analytics-api"
    namespace = data.kubernetes_namespace_v1.existing.metadata[0].name
  }
}

output "existing_kubernetes_namespace" {
  description = "Existing namespace read by Terraform."
  value       = data.kubernetes_namespace_v1.existing.metadata[0].name
}

output "existing_analytics_api_service" {
  description = "Existing API service read by Terraform."
  value = {
    name      = data.kubernetes_service_v1.analytics_api.metadata[0].name
    namespace = data.kubernetes_service_v1.analytics_api.metadata[0].namespace
    type      = data.kubernetes_service_v1.analytics_api.spec[0].type
  }
}



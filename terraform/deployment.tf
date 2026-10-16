resource "kubernetes_deployment_v1" "analytics_api" {
  wait_for_rollout = true
  metadata {
    name      = "analytics-api"
    namespace = "devops-platform"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "analytics-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "analytics-api"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name              = "analytics-api"
          image             = "cloud-devops-analytics-api:1.0"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = 15
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}





resource "kubernetes_deployment" "terraform_k8s_demo" {
  metadata {
    name = "my-deploy"
    namespace = kubernetes_namespace.k8s_terraform.id
    labels = {
      test = "terraform-k8s-demo"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "terraform-k8s-demo"
      }
    }

    template {
      metadata {
        labels = {
          test = "terraform-k8s-demo"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "con1"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
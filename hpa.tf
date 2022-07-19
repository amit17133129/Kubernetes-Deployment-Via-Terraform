resource "kubernetes_horizontal_pod_autoscaler" "my_hpa" {
  metadata {
    name      = "k8s-terraform-hpa"
    namespace = kubernetes_namespace.k8s_terraform.id
  }

  spec {
    max_replicas = 16
    min_replicas = 5

    target_cpu_utilization_percentage = 80

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "my-deploy"
    }
  }
}
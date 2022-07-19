resource "kubernetes_namespace" "k8s_terraform" {
  metadata {
    name = "k8s-terraform-demo"
  }
}
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

resource "helm_release" "nginx" {
  name       = "nginx-chart"
  chart      = "./nginx-chart-0.1.0.tgz"
  namespace  = "default"

  values = [
    file("nginx-chart/values.yaml")
  ]
}
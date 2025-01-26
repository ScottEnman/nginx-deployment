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
  name       = "my-nginx-chart"
  chart      = "./my-nginx-chart-0.1.0.tgz"
  namespace  = "default"

  values = [
    file("my-nginx-chart/values.yaml")
  ]
}
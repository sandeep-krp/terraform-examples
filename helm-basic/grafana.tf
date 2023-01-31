resource "helm_release" "grafana" {
    name = "grafana"
    repository = "https://charts.bitnami.com/bitnami"
    chart = "grafana"
    version = "8.2.25"
    namespace = "grafana"
    create_namespace = true
    set_sensitive {
      name = "admin.password"
      value = var.default_admin_password
    }
}

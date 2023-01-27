output "mariadb_namespace_host" {
  value = var.service_name
}

output "mariadb_cluster_host" {
  value = "${var.service_name}.${var.namespace}"
}

output "mariadb_port" {
  value = local.port
}

output "mariadb_user" {
  value = var.mariadb_user
}

output "mariadb_password" {
  value = var.mariadb_password
}

output "mariadb_db" {
  value = var.mariadb_db
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

locals {
  port     = 3306
  app      = "mariadb"
  replicas = 1
  match_labels = merge({
    "app.kubernetes.io/name"     = "mariadb"
    "app.kubernetes.io/instance" = "mariadb"
  }, var.match_labels)
  labels = merge(local.match_labels, var.labels)
  env    = "mariadb-env"
}

resource "kubernetes_stateful_set" "mariadb" {
  metadata {
    name      = var.stateful_set_name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    selector {
      match_labels = local.labels
    }
    service_name = local.app
    replicas     = local.replicas
    template {
      metadata {
        labels = local.labels
      }
      spec {
        affinity {
          pod_affinity {}
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_labels = local.match_labels
                }
                namespaces   = [var.namespace]
                topology_key = "kubernetes.io/hostname"
              }
              weight = 1
            }
          }
          node_affinity {}
        }
        security_context {
          fs_group = 1001
        }
        container {
          image = var.image_registry == "" ? "${var.image_repository}:${var.image_tag}" : "${var.image_registry}/${var.image_repository}:${var.image_tag}"
          name  = var.container_name
          env_from {
            config_map_ref {
              name = kubernetes_config_map.mariadb.metadata.0.name
            }
          }
          env {
            name = "MARIADB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata.0.name
                key  = "mariadb-mariadb-password"
              }
            }
          }
          env {
            name = "MARIADB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata.0.name
                key  = "mariadb-password"
              }
            }
          }
          env {
            name  = "MARIADB_EXTRA_FLAGS"
            value = var.mariadb_flags
          }
          port {
            name           = "tcp-mariadb"
            container_port = local.port
          }
          volume_mount {
            name       = "data"
            mount_path = "/bitnami/mariadb"
          }
          dynamic "volume_mount" {
            for_each = var.mariadb_conf != "" ? toset(["config"]) : toset([])
            content {
              name       = volume_mount.value
              mount_path = "/opt/bitnami/mariadb/conf/my_custom.cnf"
              sub_path   = "my_custom.cnf"
            }
          }
        }
        dynamic "volume" {
          for_each = var.mariadb_conf != "" ? toset(["config"]) : toset([])
          content {
            name = volume.value
            config_map {
              name = kubernetes_config_map.mariadb_conf[volume.key].metadata.0.name
            }
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.storage_size
          }
        }
        storage_class_name = var.storage_class_name
      }
    }
  }
}

resource "kubernetes_service" "mariadb" {
  metadata {
    name      = var.service_name
    namespace = var.namespace
    labels = merge({
      "service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true"
    }, local.labels)
  }
  spec {
    type                        = var.service_type
    publish_not_ready_addresses = true
    selector                    = local.match_labels
    port {
      name = "tcp-mariadb"
      port = local.port
    }
  }
  count = var.enable_service ? 1 : 0
}

resource "kubernetes_secret" "mariadb" {
  metadata {
    name      = "mariadb"
    namespace = var.namespace
    labels    = local.match_labels
  }
  type = "Opaque"
  data = {
    "mariadb-mariadb-password" = var.mariadb_root_password
    "mariadb-password"         = var.mariadb_password
  }
}

resource "kubernetes_config_map" "mariadb" {
  metadata {
    name      = local.env
    namespace = var.namespace
  }

  data = {
    BITNAMI_DEBUG        = "false"
    MARIADB_SKIP_TEST_DB = "yes"
    MARIADB_ROOT_USER    = var.mariadb_root_user
    MARIADB_USER         = var.mariadb_user
    MARIADB_DATABASE     = var.mariadb_db
  }
}

resource "kubernetes_config_map" "mariadb_conf" {
  for_each = var.mariadb_conf != "" ? toset(["config"]) : toset([])
  metadata {
    name      = "mariadb-conf"
    namespace = var.namespace
  }
  data = {
    "my_custom.cnf" = var.mariadb_conf
  }
}

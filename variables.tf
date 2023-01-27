variable "namespace" {
  description = "Namespace to deploy MariaDB"
  type        = string
  default     = "default"
}

variable "mariadb_root_user" {
  description = "Username for the root user"
  default     = "root"
  type        = string
}

variable "mariadb_root_password" {
  description = "Password for the `root` user"
  type        = string
  sensitive   = true
}

variable "mariadb_user" {
  description = "Username for the user"
  default     = "user"
  type        = string
}

variable "mariadb_password" {
  description = "Password for the user"
  type        = string
  sensitive   = true
}

variable "mariadb_db" {
  description = "Name of the default database"
  type        = string
  sensitive   = true
}

variable "stateful_set_name" {
  description = "Name of StatefulSet"
  type        = string
  default     = "mariadb"
}

variable "match_labels" {
  description = "Match labels to add to the MariaDB deployment, will be merged with labels"
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Labels to add to the MariaDB deployment"
  type        = map(any)
  default     = {}
}

variable "volum_claim_template_name" {
  description = "Name to use for the volume claim template"
  type        = string
  default     = "mariadb-pvc"
}

variable "replicas" {
  description = "Replicas to deploy in the MariaDB StatefulSet"
  type        = number
  default     = 1
}

variable "storage_size" {
  description = "Storage size for the StatefulSet PVC"
  type        = string
  default     = "10Gi"
}

variable "storage_class_name" {
  description = "Storage class to use for MariaDB PVCs"
  type        = string
  default     = ""
}

variable "image_registry" {
  description = "Image registry, e.g. gcr.io, docker.io"
  type        = string
  default     = ""
}

variable "image_repository" {
  description = "Image to start for this pod"
  type        = string
  default     = "bitnami/mariadb"
}

variable "image_tag" {
  description = "Image tag to use"
  type        = string
  default     = "10.10.2"
}

variable "container_name" {
  description = "Name of the MariaDB container"
  type        = string
  default     = "mariadb"
}

variable "enable_service" {
  description = "Enable service for MariaDB"
  type        = bool
  default     = true
}

variable "service_name" {
  description = "Name of service to deploy"
  type        = string
  default     = "mariadb"
}

variable "service_type" {
  description = "Type of service to deploy"
  type        = string
  default     = "ClusterIP"
}

### Resource common settings
variable "location" {
  type        = string
  default     = "Japan East"
  description = "Location of resource."
}

variable "terraform-tag" {
  type        = string
  default     = "terraform"
  description = "Add tag name to resource."
}


### Resource group
variable "resource_group_name" {
  type        = string
  default     = "Data-Accumulation-Platform"
  description = "Resource group name to store the created resource."
}


### Service Bus
variable "servicebus_namespace_name" {
  type        = string
  default     = "Data-Accumulation-Platform"
  description = "Name for Azure Service Bus namespace."
}

variable "servicebus_sku" {
  type        = string
  default     = "Standard"
  description = "SKU for Azure Service Bus namespace."
}

variable "servicebus_auth_rule_name_amqp10-converter" {
  type        = string
  default     = "amqp10-converter"
  description = "Azure Service Bus shared policy name used by amqp10-converter."
}

variable "servicebus_diag_name" {
  type        = string
  default     = "ServiceBus_Logs"
  description = "Diagnostic name for Azure Service Bus."
}


### Container Registry
variable "container_registry_name" {
  type        = string
  default     = "DataAccumulationPlatform"
  description = "Name for Azure Container registry."
}

variable "container_registry_sku" {
  type        = string
  default     = "Basic"
  description = "SKU for Azure Container Registry."
}

variable "container_registry_admin_enabled" {
  type        = bool
  default     = false
  description = "Admin authentication enable for Azure Container Registry."
}

variable "container_registry_diag_name" {
  type        = string
  default     = "ContainerRegistry_Logs"
  description = "Diagnostic name for Azure Service Bus."
}


### PostgreSQL
variable "psql_server_name" {
  type        = string
  default     = "data-accmulation-platform"
  description = "Name (and hostname) for Azure PostgreSQL."
}

variable "psql_server_sku_name" {
  type        = string
  default     = "GP_Gen5_2"
  description = "SKU for Azure PostgreSQL."
}

variable "psql_server_version" {
  type        = string
  default     = "11"
  description = "Version for Azure PostgreSQL.(Note: Value isn't number, it's string.)"
}

variable "psql_server_storage_mb" {
  type        = number
  default     = 5120
  description = "Storage size for Azure PostgreSQL. Unit is MiB."
}

variable "psql_server_backup_retention_days" {
  type        = number
  default     = 7
  description = "Retention days for Azure PostgreSQL backup."
}

variable "psql_server_auto_grow_enabled" {
  type        = bool
  default     = true
  description = "Auto grow for Azure PostgreSQL storage size."
}

variable "psql_server_geo_redundant_backup_enabled" {
  type        = bool
  default     = false
  description = "Geo redundant backup enabled for Azure PostgreSQL"
}

variable "psql_server_public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow access from public network to Azure PostgreSQL."
}

variable "psql_server_ssl_enforcement_enabled" {
  type        = bool
  default     = true
  description = "Allow access only from SSL enabled client to Azure PostgreSQL."
}

variable "psql_server_ssl_minimal_tls_version_enforced" {
  type        = string
  default     = "TLS1_0"
  description = "Allow version for SSL enabled access from this value higher."
}

variable "psql_admin_user" {
  type        = string
  default     = "psqladmin"
  description = "PostgreSQL admin username."
}

variable "psql_admin_password" {
  type        = string
  description = "PostgreSQL admin password. Set TF_VAR_psql_admin_password for environment variable."
}

variable "psql_diag_name" {
  type        = string
  default     = "PostgreSQL_Logs"
  description = "Diagnostic name for Azure PostgreSQL."
}


### Access rule for PostgreSQL
variable "psql_firewall_rule_loadbalancer" {
  type        = string
  default     = "aks-output-lb"
  description = "Firewall name for Azure PostgreSQL."
}


# Kubernetes service
variable "azuread_application_kubernetes_name" {
  type        = string
  default     = "aks-data-accumulation-platform"
  description = "Resource name used by azuread_application for kubernetes service."
}

variable "kubernetes_resource_name" {
  type        = string
  default     = "data-accumulation-aks"
  description = "Resource name for kubernetes service."
}

variable "kubernetes_dns_prefix_name" {
  type        = string
  default     = "data-accmulation-platform"
  description = "DNS prefix name for kubernetes service."
}

variable "kubernetes_version" {
  type        = string
  default     = "1.19.11"
  description = "Version for kubernetes service."
}

variable "kubernetes_node_pool_name" {
  type        = string
  default     = "agentpool"
  description = "Node pool name for kubernetes service."
}

variable "kubernetes_node_count" {
  type        = number
  default     = 3
  description = "Node count for kubernetes service."
}

variable "kubernetes_node_vm_size" {
  type        = string
  default     = "Standard_B2ms"
  description = "Node vm size for kubernetes service."
}

variable "kubernetes_node_disk_size" {
  type        = number
  default     = 30
  description = "Node disk size for kubernetes service. Unit is GiB."
}

variable "kubernetes_diag_name" {
  type        = string
  default     = "Kubernetes_Logs"
  description = "Diagnostic name for Azure Kubernetes service."
}


### amqp10-converter and IoT Agent for Json in kubernetes service.
variable "amqp10-converter_and_iotagent_replicas" {
  type        = number
  default     = 2
  description = "Replica count for amqp10-converter."
}


### amqp10-converter in kubernetes service.
variable "amqp10-converter_image_name" {
  type        = string
  default     = "ghcr.io/c-3lab/amqp10-converter"
  description = "Docker image name for amqp10-converter."
}

variable "amqp10-converter_log_level" {
  type        = string
  default     = "DEBUG"
  description = "Log level for amqp10-converter."
}


### IoT Agent for JSON in kubernetes service.
variable "iotagent_image_name" {
  type        = string
  default     = "docker.io/fiware/iot-agent:1.18.0"
  description = "Docker image name for IoT Agent for JSON."
}

variable "iotagent_loglevel" {
  type        = string
  default     = "DEBUG"
  description = "Verbose level for Fiware-IoT Agent output log."
}

variable "mongodb_iot_agent_username" {
  type        = string
  default     = "iotagentjson"
  description = "Username for MongoDB. (Fiware IoT Agent)"
}

variable "mongodb_iot_agent_password" {
  type        = string
  description = "Password for MongoDB. (Fiware IoT Agent) Set TF_VAR_iotagent_mongodb_password for environment variable."
}

variable "mongodb_iot_agent_database_name" {
  type        = string
  default     = "iotagentjson"
  description = "Database name for MongoDB. (Fiware IoT Agent)"
}


### Fiware Orion in Kubernetes service
variable "orion_replicas" {
  type        = number
  default     = 2
  description = "Replica count for orion."
}

variable "orion_image_name" {
  type        = string
  default     = "docker.io/fiware/orion:3.1.0"
  description = "Docker image name for orion"
}

variable "orion_loglevel" {
  type        = string
  default     = "DEBUG"
  description = "Verbose level for Fiware-orion output log."
}

variable "mongodb_username" {
  type        = string
  default     = "orion"
  description = "Username for MongoDB."
}

variable "mongodb_password" {
  type        = string
  description = "Password for MongoDB. Set TF_VAR_mongodb_password for environment variable."
}


### Fiware Cygnus in Kubernetes service
variable "cygnus_replicas" {
  type        = number
  default     = 2
  description = "Replica count for cygnus."
}

variable "cygnus_image_name" {
  type        = string
  default     = "docker.io/fiware/cygnus-ngsi:2.10.0"
  description = "Docker image name for cygnus"
}

variable "cygnus_loglevel" {
  type        = string
  default     = "DEBUG"
  description = "Verbose level for Fiware-cygnus output log."
}


### Kong gateway in Kubernetes service.
variable "kong_replicas" {
  type        = number
  default     = 2
  description = "Replica count for kong gateway."
}

variable "kong_image_name" {
  type        = string
  default     = "docker.io/kong:2.5.0"
  description = "Docker image name for kong gateway."
}

variable "kong_public_ip_name" {
  type        = string
  default     = "aks_kong-gateway"
  description = "Public IP address resource name for kong gateway."
}

variable "kong_public_ip_domain_name" {
  type        = string
  default     = "data-accumulation-platform"
  description = "Public IP address domain label name for kong gateway."
}

variable "psql_kong_user" {
  type        = string
  default     = "kong"
  description = "PostgreSQL kong-gateway username."
}

variable "psql_kong_password" {
  type        = string
  description = "PostgreSQL kong password. Set TF_VAR_psql_kong_password for environment variable."
}


### MongoDB
variable "mongodb_host" {
  type        = string
  default     = "platform-clus0-shard-00-00.xxxxx.azure.mongodb.net,platform-clus0-shard-00-01.xxxxx.azure.mongodb.net,platform-clus0-shard-00-02.xxxxx.azure.mongodb.net"
  description = "MongoDB host."
}

variable "mongodb_host_port" {
  type        = string
  default     = "platform-clus0-shard-00-00.xxxxx.azure.mongodb.net:27017,platform-clus0-shard-00-01.xxxxx.azure.mongodb.net:27017,platform-clus0-shard-00-02.xxxxx.azure.mongodb.net:27017"
  description = "MongoDB host."
}

variable "mongodb_rsname" {
  type        = string
  default     = "atlas-xxxxxx-shard-0"
  description = "MongoDB RplSet name."
}

variable "mongodb_timeout" {
  type        = number
  default     = "10000"
  description = "Connect timeout for MongoDB."
}

variable "mongodb_authdb" {
  type        = string
  default     = "admin"
  description = "Temporary database name required when connecting to MongoDB which requires authentication."
}


### Log Analytics Workspace
variable "log_analytics_workspace_name" {
  type        = string
  default     = "Data-Accumulation-Platform-LogAnalytics"
  description = "Name for Azure Log Analytics Workspace."
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = "PerGB2018"
  description = "Sku  for Azure Log Analytics Workspace. (Static value.) "
}

variable "log_analytics_workspace_retention_in_days" {
  type        = number
  default     = 181
  description = "Retention days for Azure Log Analytics Workspace."
}

variable "log_analytics_workspace_diag_name" {
  type        = string
  default     = "LogAnalytics_Logs"
  description = "Diagnostic name for Azure Log Analytics Workspace."
}


### Storage Account
variable "storage_account_name" {
  type        = string
  default     = "dataaccumulationplatform"
  description = "Name for Azure Storage Account."
}

variable "storage_account_tier" {
  type        = string
  default     = "Standard"
  description = "Tier for Azure Storage Account."
}

variable "storage_account_replication_type" {
  type        = string
  default     = "LRS"
  description = "Replication type for Azure Storage Account."
}

variable "storage_account_access_tier" {
  type        = string
  default     = "Cool"
  description = "Default access tier for Azure Storage Account."
}


### Blob Storage
variable "blob_storage_container_name" {
  type        = string
  default     = "logs"
  description = "Name for Azure Blob Storage Container."
}

variable "blob_storage_container_container_access_type" {
  type        = string
  default     = "private"
  description = "Access type for Azure Blob Storage Container."
}


### Azure Functions
variable "azuread_application_function_log-migration_name" {
  type        = string
  default     = "sp-log-migration-data-accmulation-platform"
  description = "Resource name used by azuread_application for Azure Fcuntions."
}

variable "function_app_log-migration_name" {
  type        = string
  default     = "LogManipulator"
  description = "Resource name for Azure Fcuntions. (LogManipulator)"
}

variable "function_app_log-migration_diag_name" {
  type        = string
  default     = "LogManipulator_Logs"
  description = "Diag name for Azure Fcuntions. (LogManipulator)"
}

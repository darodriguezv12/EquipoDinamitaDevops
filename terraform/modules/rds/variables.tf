variable "name_prefix" {
  description = "Prefix used for RDS resource names."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets used by the DB subnet group."
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID attached to RDS."
  type        = string
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_username" {
  description = "Database master username."
  type        = string
}

variable "db_password" {
  description = "Database master password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Optional maximum allocated storage in GiB."
  type        = number
  nullable    = true
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
}

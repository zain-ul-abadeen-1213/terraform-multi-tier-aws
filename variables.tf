variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix used for all resources"
  type        = string
  default     = "multitier-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the application tier"
  type        = string
  default     = "t3.micro"
}

variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
  default     = "appadmin"
}

variable "db_password" {
  description = "Master password for the RDS database (pass via TF_VAR_db_password or a local .tfvars file - never commit it)"
  type        = string
  sensitive   = true
}

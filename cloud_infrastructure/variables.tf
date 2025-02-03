data "aws_caller_identity" "current" {}

variable "aws_region" {
  default     = "eu-central-1"
  type        = string
  description = "Name of the AWS region"
}

variable "environment" {
  default     = ""
  type        = string
  description = "Name of the environment"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "public_subnet_cidr" {
  type        = list(object({ cidr = string, az = string }))
  description = "List of public subnet cidr blocks"
}

variable "private_subnet_cidr" {
  type        = list(object({ cidr = string, az = string }))
  description = "List of private subnet cidr blocks"
}

variable "node_group_ami" {
  default     = "ami-09d1e571bca42994a"
  type        = string
  description = "AMI type for the EKS node group"
}

variable "node_group_instance_type" {
  default     = "m5.large"
  type        = string
  description = "Instance type for the EKS node group"
}

variable "rds_db_username" {
  type        = string
  description = "Username of the RDS database"
  sensitive   = true
}

variable "rds_db_password" {
  type        = string
  description = "Password of the RDS database"
  sensitive   = true
}

variable "eks_cluster_permissions" {
  type        = list(object({ principal_arn = string, permission_ploicy_arn = string }))
  description = "List of permissions for the EKS cluster"
}

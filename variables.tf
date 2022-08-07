variable "region" {
  description = "AWS region "
  type  = string
  default = "eu-west-1"
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "wordpress_external_port" {
  description = "port to access from internet"
  type        = number
  default     = 80
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "endpoint" {
  description = "wordpress endpoint"
  type        = string
}

variable "rds_instance_type" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "database_master_username" {
  description = "Wordpress database master username"
  type        = string
}

variable "database_name" {
  description = "Wordpress database name"
  type        = string
}
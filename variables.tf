variable "aws_region" {}
variable "vpc_cidr_block" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "bucket_name" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}
variable "allocated_storage" {}
variable "engine_version" {}
variable "lambda_ingest_name" {}
variable "lambda_api_name" {}
variable "lambda_name" {}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}
#variable "rds_endpoint" {}
#variable "bucket_name" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "vpc_id" {}
variable "rds_address" {}
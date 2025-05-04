variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}
variable "allocated_storage" {}
variable "engine_version" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "vpc_id" {}

variable "lambda_sg_id" {
  description = "Security group ID of the Lambda function"
  type        = string
}

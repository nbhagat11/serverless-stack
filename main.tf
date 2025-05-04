terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "rds" {
  source                = "./modules/rds"
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  allocated_storage     = var.allocated_storage
  engine_version        = var.engine_version
  private_subnet_ids    = module.vpc.private_subnet_ids
  vpc_id                = module.vpc.vpc_id
  lambda_sg_id          = module.lambda_ingest.lambda_sg_id
}

module "lambda_ingest" {
  source        = "./modules/lambda_ingest"
  lambda_name   = var.lambda_ingest_name
  bucket_name   = var.bucket_name
  #rds_endpoint  = module.rds.db_endpoint
  rds_address    = module.rds.db_address
  db_user       = var.db_username
  db_password   = var.db_password
  db_name       = var.db_name
  private_subnet_ids  = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
}

module "lambda_api" {
  source        = "./modules/lambda_api"
  lambda_name   = var.lambda_api_name
  #rds_endpoint  = module.rds.db_endpoint
  rds_address    = module.rds.db_address
  db_user       = var.db_username
  db_password   = var.db_password
  db_name       = var.db_name
  private_subnet_ids  = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
}

module "api_gateway" {
  source              = "./modules/api_gateway"
  lambda_api_invoke_arn = module.lambda_api.lambda_api_invoke_arn
  lambda_api_function_name = module.lambda_api.lambda_api_function_name
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "api_url" {
  value = module.api_gateway.api_endpoint
}

output "api_route_summary" {
  value = "/summary"
}

output "db_username" {
  value = var.db_username
}

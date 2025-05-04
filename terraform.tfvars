aws_region         = "us-east-1"
vpc_cidr_block     = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

bucket_name        = "opensky-dataset-bucket"

db_name            = "opensky_dataset"
db_username        = "admin123"
db_password        = "SuperSecret123!"
db_instance_class  = "db.t3.micro"
allocated_storage  = 20
engine_version     = "8.0.33"
lambda_ingest_name = "ingest_lambda"
lambda_api_name    = "lambda_api"
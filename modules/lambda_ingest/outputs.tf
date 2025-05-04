output "lambda_arn" {
  value = aws_lambda_function.ingest.arn
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}
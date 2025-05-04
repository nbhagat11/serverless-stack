output "lambda_api_function_name" {
  value       = aws_lambda_function.lambda_api.function_name
}

output "lambda_api_function_arn" {
  value       = aws_lambda_function.lambda_api.arn
}

output "lambda_api_invoke_arn" {
  value       = aws_lambda_function.lambda_api.invoke_arn
}
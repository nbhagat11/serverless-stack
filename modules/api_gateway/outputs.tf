#output "api_url" { value = aws_apigatewayv2_api.http_api.api_endpoint }


output "api_id" {
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_endpoint" {
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}


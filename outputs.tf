output "private_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."
}
output "public_ip_addr" {
  value       = aws_instance.server.public_ip
  description = "The private IP address of the main server instance."
}

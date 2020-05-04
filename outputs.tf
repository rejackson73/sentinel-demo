output "private_ip_addr" {
  value       = aws_instance.compute.private_ip
  description = "The private IP address of the main server instance."
}
output "public_ip_addr" {
  value       = aws_instance.compute.public_ip
  description = "The public IP address of the main server instance."
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_url" {
  value = "http://${aws_instance.backend.public_ip}:${var.backend_port}"
}

output "frontend_url" {
  value = "http://${aws_instance.frontend.public_ip}:${var.frontend_port}"
}
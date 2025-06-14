output "frontend_url" {
  value = "http://${aws_instance.fullstack_app.public_ip}:3000"
}

output "backend_url" {
  value = "http://${aws_instance.fullstack_app.public_ip}:5000"
}
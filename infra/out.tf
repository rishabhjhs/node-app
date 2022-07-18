output "repository_url" {
  value = aws_ecr_repository.app_repository.repository_url
  description = "url where the docker image is to be pushed"
}

output "web_endpoint" {
  value = "http://${aws_lb.app_load_balancer.dns_name}"
  description = "hit this url to access web server"
}
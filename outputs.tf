output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "Public DNS name of the load balancer - open this in a browser after apply"
  value       = aws_lb.app.dns_name
}

output "rds_endpoint" {
  description = "Connection endpoint of the RDS database"
  value       = aws_db_instance.main.endpoint
}

output "asg_name" {
  description = "Name of the application-tier Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

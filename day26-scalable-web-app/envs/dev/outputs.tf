output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = module.alb.target_group_arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = module.asg.asg_arn
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = module.ec2.launch_template_id
}


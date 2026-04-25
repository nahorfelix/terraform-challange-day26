variable "app_name" {
  description = "Application name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for web instances"
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ASG"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "ASG min size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "ASG max size"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "ASG desired instances"
  type        = number
  default     = 2
}

variable "cpu_scale_out_threshold" {
  description = "CPU percent threshold to scale out"
  type        = number
  default     = 70
}

variable "cpu_scale_in_threshold" {
  description = "CPU percent threshold to scale in"
  type        = number
  default     = 30
}


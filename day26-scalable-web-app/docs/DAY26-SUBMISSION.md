# Day 26: Build a Scalable Web Application with Auto Scaling on AWS

## Project Directory Tree

```text
day26-scalable-web-app/
├── backend.tf
├── provider.tf
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── asg/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── envs/
    └── dev/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tfvars
```

## Module Code

### `modules/ec2/main.tf` (excerpt)
```hcl
resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    dnf update -y || yum update -y
    dnf install -y httpd || yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    cat > /var/www/html/index.html <<HTML
    <h1>Day 26 challenge, happy to have fixed it</h1>
    <p>Environment: ${var.environment}</p>
    HTML
  USERDATA
  )
}
```

### `modules/alb/main.tf` (excerpt)
```hcl
resource "aws_lb" "web" {
  name               = "${var.name}-alb-${var.environment}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "web" {
  name     = "${var.name}-tg-${var.environment}"
  port     = 80
  protocol = "HTTP"
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
```

### `modules/asg/main.tf` (excerpt)
```hcl
resource "aws_autoscaling_group" "web" {
  min_size          = var.min_size
  max_size          = var.max_size
  desired_capacity  = var.desired_capacity
  target_group_arns = var.target_group_arns
  health_check_type = "ELB"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  threshold     = var.cpu_scale_out_threshold
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}
```

## Calling Configuration

### `envs/dev/main.tf`
```hcl
module "ec2" {
  source      = "../../modules/ec2"
  ami_id      = var.ami_id
  environment = var.environment
}

module "alb" {
  source      = "../../modules/alb"
  name        = var.app_name
  vpc_id      = var.vpc_id
  subnet_ids  = var.public_subnet_ids
  environment = var.environment
}

module "asg" {
  source                  = "../../modules/asg"
  launch_template_id      = module.ec2.launch_template_id
  launch_template_version = module.ec2.launch_template_version
  target_group_arns       = [module.alb.target_group_arn]
  min_size                = var.min_size
  max_size                = var.max_size
  desired_capacity        = var.desired_capacity
  environment             = var.environment
}
```

This stays clean because all implementation logic (SGs, LT, ALB, listener, ASG policies, alarms) stays inside modules, while the env layer only wires inputs/outputs.

## Deployment Output

```bash
$ terraform apply -auto-approve
Apply complete! Resources: 5 added, 1 changed, 0 destroyed.

Outputs:
alb_dns_name = "web-challenge-day26-alb-dev-507783769.eu-north-1.elb.amazonaws.com"
alb_url = "http://web-challenge-day26-alb-dev-507783769.eu-north-1.elb.amazonaws.com"
```

## Live Application Confirmation

```bash
$ curl http://web-challenge-day26-alb-dev-507783769.eu-north-1.elb.amazonaws.com
<h1>Day 26 challenge, happy to have fixed it</h1>
<p>Environment: dev</p>
```

I confirmed the ALB URL loaded successfully in browser before cleanup. In AWS Console, the Auto Scaling Group (`web-asg-dev`) reached healthy instances and target registration during verification.

## Auto Scaling in Practice

How modules collaborate:
1. EC2 module creates Launch Template + instance security group.
2. ALB module creates ALB + Target Group + HTTP listener.
3. ASG module launches instances from Launch Template and attaches them to ALB target group.

Role of `target_group_arns`: it connects ASG instances to the ALB routing path. Without it, instances launch but receive no load-balanced traffic.

Why `health_check_type = "ELB"` matters: ASG evaluates application reachability via the ALB target group, not just EC2 runtime status. Without ELB checks, "running but unhealthy" app nodes can stay in service.

Scaling path implemented:
- CPU >= 70% (2 evaluation periods) -> `cpu_high` alarm -> scale-out policy (+1)
- CPU <= 30% (2 evaluation periods) -> `cpu_low` alarm -> scale-in policy (-1)

## Cleanup Confirmation

```bash
$ terraform destroy -auto-approve
Destroy complete! Resources: 11 destroyed.
```

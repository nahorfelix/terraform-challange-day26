# Day 26 — Scalable web app with ALB + ASG (Terraform)

Repository for Terraform Challenge Day 26: reusable modules for EC2 Launch Template, ALB, and ASG with CloudWatch scaling alarms.

## Structure

- `day26-scalable-web-app/modules/ec2` — Launch template + instance SG
- `day26-scalable-web-app/modules/alb` — ALB + target group + listener
- `day26-scalable-web-app/modules/asg` — ASG + scale policies + CPU alarms
- `day26-scalable-web-app/envs/dev` — calling configuration

## Run

```powershell
Set-Location day26-scalable-web-app/envs/dev
terraform init
terraform validate
terraform plan
terraform apply
terraform output alb_dns_name
```

## Important

- Replace placeholder values in `envs/dev/terraform.tfvars` (`vpc_id`, subnet IDs).
- Current IAM user cannot run `DescribeVpcs` / `DescribeSubnets` from CLI due policy limits.
- Destroy after verification to avoid charges:

```powershell
terraform destroy
```


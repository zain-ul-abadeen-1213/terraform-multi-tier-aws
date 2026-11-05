# Multi-Tier AWS Infrastructure with Terraform

Infrastructure as Code for a classic **three-tier architecture** on AWS: a public load-balancer tier, a private application tier with Auto Scaling, and a private database tier — all inside one VPC spanning two Availability Zones.

The configuration is complete and passes `terraform validate`. It has **not been applied yet** — applying creates billable resources, so the plan is reviewed first (see *Cost notes*).

---

## Architecture

```
                        Internet
                           |
                    [ Internet Gateway ]
                           |
        ┌──────────────────┴──────────────────┐
        |              VPC 10.20.0.0/16        |
        |                                      |
        |  Public subnets (one per AZ)         |
        |    └─ Application Load Balancer      |
        |             |  (SG: HTTP from 0.0.0.0/0)
        |  Private app subnets (one per AZ)    |
        |    └─ Auto Scaling Group (EC2)       |
        |       min 2 · desired 2 · max 4      |
        |             |  (SG: HTTP only from ALB)
        |  Private DB subnets (one per AZ)     |
        |    └─ RDS MySQL 8.0                  |
        |       (SG: MySQL only from app tier) |
        └──────────────────────────────────────┘
        Private subnets reach the internet for updates via one NAT Gateway.
```

**Design rules that matter:**

- **Nothing in the private tiers is reachable from the internet.** The app servers and the database have no public IPs; traffic arrives only through the load balancer.
- **Security groups are chained** — each tier accepts traffic only from the tier in front of it (ALB → app → DB), never from a CIDR range.
- **Two Availability Zones** for subnets, the ASG, and the DB subnet group, so the design survives an AZ outage.
- **One NAT Gateway** instead of one per AZ — a deliberate practice-environment cost saving (production would use one per AZ, noted in the code).

## Files

| File | Contents |
|---|---|
| `providers.tf` | Terraform + AWS provider requirements, region, default tags |
| `variables.tf` | Region, project name, VPC CIDR, instance type, DB credentials (password is `sensitive`, no default) |
| `vpc.tf` | VPC, 6 subnets (2 per tier), Internet Gateway, NAT Gateway, route tables |
| `security.tf` | The three chained security groups (ALB / app / DB) |
| `compute.tf` | ALB + target group + listener, launch template, Auto Scaling Group, RDS MySQL |
| `outputs.tf` | VPC ID, ALB DNS name, RDS endpoint, ASG name |
| `terraform.tfvars.example` | Example variable values — copy to `terraform.tfvars` and fill in your own |

## Usage

```bash
# 1. Configure AWS credentials first (aws configure) with an IAM user.

# 2. Prepare variables
cp terraform.tfvars.example terraform.tfvars   # then edit, set a strong db_password

# 3. Initialise (downloads the AWS provider)
terraform init

# 4. Check the code
terraform validate
terraform fmt -check

# 5. Review exactly what would be created — creates nothing
terraform plan

# 6. Create (billable — see cost notes) / clean up everything afterwards
terraform apply
terraform destroy
```

Real `terraform.tfvars` and state files are git-ignored and must never be committed.

## Cost notes

`terraform apply` creates resources that cost money while they exist — mainly the **NAT Gateway**, the **Application Load Balancer**, the **RDS instance**, and the **EC2 instances**. Review `terraform plan` carefully before applying, and run `terraform destroy` as soon as practice is finished.

## Skills demonstrated

Terraform (providers, variables, locals, count, data sources, outputs, sensitive values) · AWS VPC design (subnets, route tables, IGW, NAT) · load balancing and Auto Scaling · RDS · security-group design · cost-aware infrastructure decisions

---

## Author

**Zain Ul Abdin** — Founder, **Zain Tech Automation Solutions** · Karachi, Pakistan
GitHub: [@zain-ul-abadeen-1213](https://github.com/zain-ul-abadeen-1213)

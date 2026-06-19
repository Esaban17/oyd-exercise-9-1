# oyd-exercise-9-1 — Observability Module

**Course:** Optimizaciones y Desempeño — Cloud Deployment Automation  
**Session:** 9 — June 18, 2026  
**Exercise:** 9.1 — Observability

## Overview

Terraform module that adds a complete observability stack for **FinAPI**, a fintech startup processing
payment requests behind an Application Load Balancer on AWS:

| Resource | Description |
|---|---|
| `aws_cloudwatch_log_group` | `/finapi/dev` — 14-day retention |
| `aws_sns_topic` | `finapi-alerts` — single notification topic |
| `aws_sns_topic_subscription` | Email subscription for alarm notifications |
| `aws_cloudwatch_metric_alarm` (×3) | HTTP 5xx errors, ALB latency, EstimatedCharges billing |
| `aws_budgets_budget` | Monthly cost ceiling with 80% threshold alert |

## Repository Structure

```
oyd-exercise-9-1/
├── versions.tf               # Terraform + AWS provider (default + us_east_1 alias)
├── main.tf                   # Root module — calls observability module
├── variables.tf              # Input variables
├── outputs.tf                # Exposes module outputs
├── envs/
│   └── dev/
│       └── dev.tfvars        # Dev environment values
├── modules/
│   └── observability/
│       ├── main.tf           # All observability resources
│       ├── variables.tf      # Module input variables
│       └── outputs.tf        # Module outputs
└── evidence/                 # Screenshots for Acceptance Criteria
    ├── log-group.png
    ├── alarm.png
    └── sns-confirmed.png
```

## Prerequisites

- Terraform >= 1.6
- AWS CLI configured (`aws sts get-caller-identity` should succeed)
- An email address you can check — AWS sends an SNS subscription confirmation you must click

## Usage

```bash
terraform init
terraform apply -var-file="envs/dev/dev.tfvars"
```

After apply, check your email and **click the SNS subscription confirmation link**.

## Acceptance Criteria

- [x] `modules/observability/main.tf` declares `aws_cloudwatch_log_group`, `aws_sns_topic`,
  `aws_sns_topic_subscription`, `aws_cloudwatch_metric_alarm` × 3, and `aws_budgets_budget`
- [x] `EstimatedCharges` alarm sets `provider = aws.us_east_1`
- [x] Root `versions.tf` has `provider "aws"` block with `alias = "us_east_1"` and `region = "us-east-1"`
- [x] `terraform apply` completes without errors
- [ ] Log group `/finapi/dev` visible in CloudWatch console → `evidence/log-group.png`
- [ ] At least one alarm in ALARM or OK state → `evidence/alarm.png`
- [ ] SNS subscription status shows **Confirmed** → `evidence/sns-confirmed.png`

## Evidence

Screenshots are saved in the `evidence/` folder after a successful `terraform apply` and SNS
subscription confirmation.

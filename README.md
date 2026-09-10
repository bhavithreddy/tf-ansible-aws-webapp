# Terraform + Ansible AWS Web App Deployment

A small, production-grade AWS infrastructure project demonstrating Terraform (provisioning) and Ansible (configuration management) working together to deploy a Flask application — built cost-consciously for a portfolio/resume context.

## Architecture

                Internet
                    |
               [Port 80]
                    |
        ┌───────────────────────┐
        │   EC2 t3.micro         │
        │   Amazon Linux 2023    │
        │                        │
        │   Nginx (reverse proxy)│
        │        │               │
        │        ▼               │
        │   Flask app (systemd)  │
        │   127.0.0.1:5000       │
        └───────────────────────┘
                    │
        VPC (10.20.0.0/16)
        Public subnet + IGW
        Security Group: 22 (my IP only), 80 (public)
        IAM role: SSM-enabled EC2 instance profile




## What this demonstrates

- **Terraform**: modular AWS resource provisioning (VPC, subnet, IGW, route table, security group, IAM role/instance profile, key pair, EC2), variable-driven configuration, remote outputs
- **Ansible**: dynamic inventory via the `amazon.aws.aws_ec2` plugin (no hardcoded IPs — inventory is always in sync with what's actually running), role-based playbook structure, Jinja2 templating, systemd service management, idempotent configuration (verified: a second run reports `changed=0` across all tasks)
- **Security practices**: SSH restricted to a single IP via security group, least-privilege-oriented IAM role (SSM access only, no broad permissions), no hardcoded secrets
- **Cost discipline**: no ALB, NAT Gateway, or RDS — architecture deliberately sized for a single free-tier-eligible EC2 instance, with documented teardown

## Tech stack

- **Infrastructure**: Terraform >= 1.5, AWS provider ~> 5.0
- **Configuration management**: Ansible 2.16+, `amazon.aws` collection
- **App**: Python 3 / Flask
- **Web server**: Nginx (reverse proxy)
- **Cloud**: AWS (EC2, VPC, IAM)

## Prerequisites

- AWS account with a scoped IAM user (not root) configured via `aws configure`
- Terraform >= 1.5
- Ansible >= 2.14, `amazon.aws` collection (`ansible-galaxy collection install amazon.aws`)
- `boto3`/`botocore` installed (`pip3 install boto3 botocore --break-system-packages` on Ubuntu/WSL)
- An SSH key pair generated locally (`ssh-keygen -t ed25519`)
- **Important**: this project must run on a native Linux filesystem in WSL (e.g. `~/projects/...`), not a Windows-mounted path (`/mnt/c/...`) — Ansible refuses to trust config files on world-writable mounted drives

## Deploy

```bash
# 1. Provision infrastructure
cd terraform
# create terraform.tfvars with your public IP: my_ip_cidr = "X.X.X.X/32"
terraform init
terraform plan
terraform apply

# 2. Configure the server
cd ../ansible
ansible-inventory -i inventory/aws_ec2.yml --graph   # confirm dynamic inventory finds the instance
ansible-playbook playbook.yml
```

## Verify

```bash
curl http://<instance_public_ip>/
curl http://<instance_public_ip>/health
```

Expected: JSON responses confirming the Flask app is reachable through Nginx.

## Cost

Deliberately minimized:
- t3.micro EC2 instance (free-tier eligible on new AWS accounts; otherwise ~$0.0104/hr)
- 8GB gp3 EBS volume
- No ALB, NAT Gateway, RDS, or Elastic IP (each would add ongoing cost)
- **Estimated cost while running**: under $0.30/day if outside free tier
- **Cost while destroyed**: $0

## Teardown

This project is designed to be fully destroyed between sessions to avoid any ongoing cost:

```bash
cd terraform
terraform destroy
```

Confirms and removes all 11 AWS resources. No orphaned resources remain (no EIP, no persistent storage outside the instance's own root volume, which is destroyed with it).

## Design decisions

- **No ALB**: adds ~$16/mo in idle cost for a single-instance demo project; a direct EC2 public IP is sufficient to prove the deployment pattern. In a real multi-instance production setup, an ALB would be standard.
- **No NAT Gateway**: the instance lives in a public subnet by design, since there's no private-subnet resource needing outbound-only internet access. A NAT Gateway would be necessary for a private-subnet architecture (e.g., app servers behind a load balancer, or a database tier).
- **Local Terraform state**: reasonable for a single-operator project; a team environment would use an S3 backend with DynamoDB state locking to prevent concurrent-apply conflicts.
- **Dynamic Ansible inventory over static**: avoids hardcoding IPs that change on every `terraform apply`/instance restart; the `aws_ec2` plugin queries AWS directly by tag, keeping infrastructure and configuration management in sync automatically.
- **IAM role includes SSM access**: provides a secondary access path (AWS Systems Manager Session Manager) independent of SSH, in case SSH access is ever lost (e.g., security group misconfiguration, key loss).

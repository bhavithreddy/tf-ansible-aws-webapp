variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for tagging all resources"
  type        = string
  default     = "tf-ansible-webapp"
}

variable "instance_type" {
  description = "EC2 instance type (kept small deliberately for cost)"
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the single public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "availability_zone" {
  description = "AZ for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "ssh_public_key_path" {
  description = "Path to the local SSH public key to register as an AWS key pair"
  type        = string
  default     = "~/.ssh/tf-ansible-project/webapp-key.pub"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form (e.g. 1.2.3.4/32), used to restrict SSH access"
  type        = string
  # No default on purpose - forces you to set this in tfvars so SSH
  # is never accidentally left open to 0.0.0.0/0.
}

variable "app_port" {
  description = "Port the Flask app listens on internally (Nginx proxies to this)"
  type        = number
  default     = 5000
}
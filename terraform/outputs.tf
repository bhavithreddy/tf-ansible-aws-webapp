output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "ssh_command" {
  description = "Ready-to-use SSH command"
  value       = "ssh -i ~/.ssh/tf-ansible-project/webapp-key ec2-user@${aws_instance.web.public_ip}"
}

output "app_url" {
  description = "URL to verify the app once Ansible has configured it"
  value       = "http://${aws_instance.web.public_ip}"
}
output "master_public_ip" {
  value       = aws_instance.master.public_ip
  description = "Public IP of the master node"
}

output "master_private_ip" {
  value       = aws_instance.master.private_ip
  description = "Private IP of the master node"
}

output "worker1_public_ip" {
  value       = aws_instance.worker1.public_ip
  description = "Public IP of worker node 1"
}

output "worker2_public_ip" {
  value       = aws_instance.worker2.public_ip
  description = "Public IP of worker node 2"
}

output "kubeconfig_instructions" {
  value = "To configure kubectl, SSH to master and copy kubeconfig: scp -i your-key.pem ubuntu@${aws_instance.master.public_ip}:~/.kube/config ~/.kube/config"
}

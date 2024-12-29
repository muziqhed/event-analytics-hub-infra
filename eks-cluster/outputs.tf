
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}


output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.ea-hub.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.ea-hub.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.ea-hub.username
  sensitive   = true
}

output "docdb_endpoint" {
  value       = aws_docdb_cluster.docdb.endpoint
  description = "DocumentDB Cluster Endpoint"
}

output "docdb_port" {
  value       = aws_docdb_cluster.docdb.port
  description = "DocumentDB Cluster Port"
}

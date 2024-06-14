# Set write access for external managed-aws-rds service
service "managedcloudsql" {
  policy = "write"
  intentions = "read"
}
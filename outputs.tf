output "access_key_id" {
  value = aws_iam_access_key.deployer_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.deployer_key.secret
  sensitive = true
}
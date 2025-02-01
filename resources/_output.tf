output "smtp_username" {
  description = "SMTP username for Mastodon configuration"
  value       = aws_iam_access_key.smtp_user.id
}

output "smtp_password" {
  description = "SMTP password for Mastodon configuration"
  value       = local.smtp_password
  sensitive   = true
}

output "smtp_server" {
  description = "SMTP server endpoint for Mastodon configuration"
  value       = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
}

output "domain_verification_records" {
  description = "DNS records needed for domain verification"
  value = {
    verification_token = aws_ses_domain_identity.main.verification_token
    dkim_tokens        = aws_ses_domain_dkim.main.dkim_tokens
  }
}
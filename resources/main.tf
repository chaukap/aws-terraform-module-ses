data "aws_route53_zone" "domain" {
  name = var.domain
}

# SES Domain Identity
resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

# DKIM Records for Domain Verification
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

# Add verification record to Route53
resource "aws_route53_record" "domain_verification" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain_identity.verification_token]
}

# Add DKIM records to Route53
resource "aws_route53_record" "dkim_records" {
  count   = 3
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${element(aws_ses_domain_dkim.domain_dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# IAM User for SMTP Authentication
resource "aws_iam_user" "smtp_user" {
  name = "mastodon-smtp-user"
}

# IAM Access Key for SMTP Credentials
resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

# IAM Policy for SES Send Email Permission
data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = [aws_ses_domain_identity.main.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_user_policy" "ses_sender" {
  name   = "ses_sender"
  user   = aws_iam_user.smtp_user.name
  policy = data.aws_iam_policy_document.ses_sender.json
}

# Create SMTP credentials from IAM access key
locals {
  # AWS SMTP credentials must be created from IAM credentials using a specific algorithm
  # This uses a predefined AWS endpoint - no need to change per region
  smtp_password = base64encode(
    format(
      "Message\n%s\nAWS4-HMAC-SHA256\n%s\n",
      aws_iam_access_key.smtp_user.secret,
      sha256("AWS4${aws_iam_access_key.smtp_user.secret}")
    )
  )
}
# SES Domain Identity
resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

# DKIM Records for Domain Verification
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
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
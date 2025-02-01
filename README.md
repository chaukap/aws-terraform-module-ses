# AWS SES Terraform Module for Mastodon

This Terraform module sets up Amazon Simple Email Service (SES) for use with a Mastodon server. It creates all necessary resources including domain verification, DKIM settings, and SMTP credentials.

## Features

- Creates SES domain identity
- Configures DKIM for improved email deliverability
- Creates dedicated IAM user with minimal permissions
- Generates SMTP credentials compatible with Mastodon
- Provides all necessary DNS verification records

## Prerequisites

- An AWS account
- Terraform installed (version 0.13 or later)
- A domain name you control
- Access to modify DNS records for your domain

## Usage

```hcl
module "ses" {
  source = "github.com/your-username/terraform-aws-ses-mastodon"
  
  domain = "your-domain.com"
  region = "us-east-1"
}
```

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| domain | Domain name to use for sending emails | string | yes |
| region | AWS region where SES will be deployed | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| smtp_username | SMTP username for Mastodon configuration |
| smtp_password | SMTP password for Mastodon configuration |
| smtp_server | SMTP server endpoint for Mastodon configuration |
| domain_verification_records | DNS records needed for domain verification |

## Integration with Mastodon

1. Apply the Terraform configuration
2. Add the DNS records provided in `domain_verification_records` to your domain
3. Update your Mastodon `.env.production` file:

```bash
SMTP_SERVER=email-smtp.${region}.amazonaws.com
SMTP_PORT=587
SMTP_LOGIN=${smtp_username}
SMTP_PASSWORD=${smtp_password}
SMTP_FROM_ADDRESS=notifications@your-domain.com
```

## Important Notes

### SES Sandbox Mode

By default, new SES accounts are in sandbox mode, which only allows sending emails to verified addresses. To send emails to any address:

1. Go to the AWS SES Console
2. Click "Request Production Access"
3. Fill out the form describing your email sending needs
4. Wait for AWS approval (typically 24-48 hours)

### DNS Verification

After applying the Terraform configuration:

1. Get the verification records:
```bash
terraform output domain_verification_records
```

2. Add these records to your domain's DNS configuration
3. Wait for verification (can take up to 72 hours, typically much faster)

### Regional Availability

Make sure to choose a region where SES is available. Common regions include:
- us-east-1 (N. Virginia)
- us-west-2 (Oregon)
- eu-west-1 (Ireland)

## Security Considerations

This module follows AWS security best practices by:
- Creating a dedicated IAM user for SMTP
- Implementing least-privilege permissions
- Keeping SMTP credentials secure through Terraform's sensitive output

## Troubleshooting

### Common Issues

1. **DNS Verification Pending**
   - Verify DNS records are correctly added
   - Allow up to 72 hours for propagation
   - Check record formatting

2. **Cannot Send Emails**
   - Confirm SES is out of sandbox mode
   - Verify SMTP credentials in Mastodon config
   - Check for rate limiting

3. **SMTP Authentication Failures**
   - Ensure correct SMTP credentials in Mastodon config
   - Verify using correct regional endpoint
   - Check IAM user permissions

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a Pull Request

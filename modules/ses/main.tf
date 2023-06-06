resource "aws_ses_email_identity" "ses_email" {
  email = "noreply-${var.env}@${var.domain}"
}
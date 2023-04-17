resource "aws_wafv2_ip_set" "ip_set" {
  name               = var.ip_set_name
  description        = "Whitelisted IPs"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.whitelist_ips

  tags = {
    Name        = var.name
    Environment = var.env
    System      = var.system
  }
}
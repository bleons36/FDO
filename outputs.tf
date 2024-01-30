output "tfe_console_url" {
  value = "https://${aws_eip.tfe_dev_instance.public_ip}:443"
}
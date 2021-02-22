terraform {}

## Compute example

variable "GCE_ZONE" {}
variable "GCE_INSTANCE_NAME" {
  default = "gcp-free-tier"
}
variable "GCE_SSH_PUBKEY_FILE" {}
variable "GCE_SSH_USER" {
  default = "notroot"
}
variable "NOTIFICATION_CHANNEL_NAME" {
  default = ""
}

module "gcp_compute" {
  source = "./compute"
  gce_zone = var.GCE_ZONE
  gce_instance_name = var.GCE_INSTANCE_NAME
  gce_ssh_pubkey_file = var.GCE_SSH_PUBKEY_FILE
  gce_ssh_user = var.GCE_SSH_USER
  notification_channel_display_name = var.NOTIFICATION_CHANNEL_NAME
}
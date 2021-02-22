# Depends on the following environment variables to be set:
# - GOOGLE_REGION
# - GOOGLE_PROJECT
# - GOOGLE_CREDENTIALS
# - TF_VAR_google_zone
# - TF_VAR_gce_instance_pubkey
#
# Optionally, provide the following environment variables to further configure the deployment:
# - TF_VAR_gce_instance_name
provider "google" {}

variable "gce_zone" {
    type = string
}

variable "gce_instance_name" {
    type = string
    default = "gcp-free-tier"
}

variable "gce_ssh_pubkey_file" {
    type = string
}

variable "gce_ssh_user" {
    type = string
    default = "nonroot"
}

variable "notification_channel_display_name" {
    type = string
}

resource "google_compute_address" "static" {
  name = "${var.gce_instance_name}-ipv4-address"
}

data "google_compute_image" "debian_image" {
  family  = "debian-10"
  project = "debian-cloud"
}

data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_instance" "instance" {
  name         = var.gce_instance_name
  machine_type = "f1-micro"
  zone         = var.gce_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
      size = 30
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  tags = [ "allow-wireguard", "allow-web", "allow-dns", "allow-ssh" ]

  metadata = {
      ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pubkey_file)}"
  }
}

resource "google_compute_firewall" "wireguard" {
  name    = "allow-wireguard"
  network = data.google_compute_network.default.name
  direction = "INGRESS"

  source_ranges = [ "0.0.0.0/0" ]

  allow {
    protocol = "udp"
    ports    = ["51515"]
  }

  target_tags = [ "allow-wireguard" ]
}

resource "google_compute_firewall" "web" {
    name = "allow-web"
    network = data.google_compute_network.default.name
    direction = "INGRESS"

    source_ranges = [ "0.0.0.0/0" ]

    allow {
        protocol = "tcp"
        ports = [ "80", "443" ]
    }
    
    target_tags = [ "allow-web" ]
}

resource "google_compute_firewall" "dns" {
    name = "allow-dns"
    network = data.google_compute_network.default.name
    direction = "INGRESS"

    source_ranges = [ "0.0.0.0/0" ]

    allow {
        protocol = "udp"
        ports = [ "53" ]
    }

    allow {
        protocol = "tcp"
        ports = [ "53" ]
    }

    target_tags = [ "allow-dns" ]
}

resource "google_compute_firewall" "ssh" {
    name = "allow-ssh"
    network = data.google_compute_network.default.name
    direction = "INGRESS"

    source_ranges = [ "0.0.0.0/0" ]

    allow {
        protocol = "tcp"
        ports = [ "22" ]
    }

    target_tags = [ "allow-ssh" ]
}

data "google_monitoring_notification_channel" "default" {
  count = var.notification_channel_display_name != "" ? 1 : 0
  display_name = var.notification_channel_display_name
}

resource "google_monitoring_alert_policy" "alert_policy" {
  count = length(data.google_monitoring_notification_channel.default) > 0 ? 1 : 0
  display_name = "GCP Compute Free Egress"
  notification_channels = [ data.google_monitoring_notification_channel.default[0].name ]
  combiner = "OR"
  conditions {
    display_name = "Daily GCP Compute Egress Too High For Free Tier"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\" AND resource.type=\"gce_instance\""
      duration   = "86400s"
      comparison = "COMPARISON_GT"
      threshold_value = 35791394
      aggregations {
        alignment_period   = "3600s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

output "gce_external_ip" {
    value = google_compute_address.static.address
}
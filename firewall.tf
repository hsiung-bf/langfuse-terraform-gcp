# Allow internal traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "langfuse-allow-internal"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/16"]
}

# Allow SSH access from specific IP ranges
resource "google_compute_firewall" "allow_ssh" {
  name    = "langfuse-allow-ssh"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Note: In production, restrict this to specific IP ranges
}

# Allow HTTP/HTTPS traffic
resource "google_compute_firewall" "allow_http_https" {
  name    = "langfuse-allow-http-https"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
} 
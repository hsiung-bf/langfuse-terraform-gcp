# Create SSL certificate
resource "google_compute_managed_ssl_certificate" "this" {
  name = "langfuse-cert"

  managed {
    domains = [var.domain]
  }
}

# Create HTTPS target proxy
resource "google_compute_target_https_proxy" "this" {
  name             = "langfuse-https-proxy"
  url_map          = google_compute_url_map.this.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.this.self_link]
}

# Create global forwarding rule
resource "google_compute_global_forwarding_rule" "this" {
  name                  = "${var.name}-forwarding-rule"
  ip_address            = google_compute_global_address.lb.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.this.id
  load_balancing_scheme = "EXTERNAL"
}

# Create URL map
resource "google_compute_url_map" "this" {
  name            = "langfuse-url-map"
  default_service = google_compute_backend_service.this.id
}

# Create backend service
resource "google_compute_backend_service" "this" {
  name        = "${var.name}-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30
  enable_cdn  = false

  backend {
    balancing_mode = "RATE"
    max_rate      = 1000
    group         = google_compute_network_endpoint_group.this.id
  }

  health_checks = [google_compute_health_check.this.id]
}

resource "google_compute_network_endpoint_group" "this" {
  name         = "${var.name}-neg"
  network      = google_compute_network.this.id
  subnetwork   = google_compute_subnetwork.this.id
  default_port = "80"
  zone         = "${data.google_client_config.current.region}-a"
}

# Create health check
resource "google_compute_health_check" "this" {
  name               = "langfuse-health-check"
  timeout_sec        = 5
  check_interval_sec = 10

  https_health_check {
    port = "443"
  }
}

resource "google_compute_global_address" "lb" {
  name = "${var.name}-lb"
} 
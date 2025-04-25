# Create Cloud DNS zone
resource "google_dns_managed_zone" "this" {
  name        = "${replace(var.domain, ".", "-")}-public-a3"
  dns_name    = "${var.domain}."
  description = "DNS zone for Langfuse domain"
  visibility  = "public"
}

# Get the load balancer IP
data "kubernetes_ingress_v1" "langfuse" {
  metadata {
    name      = "langfuse"
    namespace = "langfuse"
  }
}

# Create DNS A record for the load balancer
resource "google_dns_record_set" "this" {
  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.this.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["34.144.221.245"]
}

# Create NS records to match parent domain
resource "google_dns_record_set" "ns" {
  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.this.name
  type         = "NS"
  ttl          = 300
  rrdatas      = [
    "ns-cloud-a1.googledomains.com.",
    "ns-cloud-a2.googledomains.com.",
    "ns-cloud-a3.googledomains.com.",
    "ns-cloud-a4.googledomains.com."
  ]
}

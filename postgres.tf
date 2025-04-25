# Generate random password for database
resource "random_password" "postgres_password" {
  length      = 64
  special     = false
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}

# Create Cloud SQL instance
resource "google_sql_database_instance" "this" {
  name             = var.name
  region           = data.google_client_config.current.region
  database_version = "POSTGRES_15"
  deletion_protection = false

  settings {
    tier                        = "db-perf-optimized-N-2"
    edition                     = "ENTERPRISE_PLUS"
    availability_type           = "REGIONAL"
    deletion_protection_enabled = false

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.this.self_link
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "02:00"
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }
  }

  depends_on = [google_service_networking_connection.private_service_connection]
}

# Create database
resource "google_sql_database" "this" {
  name     = "langfuse"
  instance = google_sql_database_instance.this.name
}

# Create database user
resource "google_sql_user" "this" {
  name     = "langfuse"
  instance = google_sql_database_instance.this.name
  password = random_password.postgres_password.result
} 
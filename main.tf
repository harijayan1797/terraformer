// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.credentials}")}"
 project     = "${var.gcp_project}" 
 region      = "${var.region}"
}

// Create VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.name}-vpc"
 auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "subnet" {
 name          = "${var.name}-subnet"
 ip_cidr_range = "${var.subnet_cidr}"
 network       = "${var.name}-vpc"
 depends_on    = ["google_compute_network.vpc"]
 region      = "${var.region}"
}
// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Create Instance
resource "google_compute_instance" "database" {
  name         = "database"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"
  tags = ["db"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  // Local SSD disk
  scratch_disk {}
  network_interface {
    network       = "${var.name}-vpc"
    subnetwork    = "${var.name}-subnet"
    access_config {
      // Ephemeral IP
    }
  }

}

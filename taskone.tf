variable "project_id" {
  description = "gcptask-380221"
}

variable "region" {
  description = "europe-west2"
}

provider "google" {
  project = var.project_id
  region  = var.region # London region
}

# Create VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "test-vpc-network"
  auto_create_subnetworks = false
}

# Create subnet within VPC network
resource "google_compute_subnetwork" "subnet" {
  name          = "test-subnet"
  ip_cidr_range = "10.0.0.0/24"  # RFC1918 24-bit block
  region        = var.region # London region
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_router" "router" {
  name    = "nat-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc_network.id
}

module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.2"
  project_id = var.project_id
  region     = var.region
  router     = google_compute_router.router.name
}

resource "google_project_service" "project" {
  project = var.project_id
  service = "iam.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = "testuser"
  display_name = "Service Account"
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

locals {
  all_service_account_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ]
}

resource "google_project_iam_member" "service_account-roles" {
  for_each = toset(local.all_service_account_roles)

  project = var.project_id
  #role    = each.value
  role   = "roles/iam.serviceAccountCreator"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

# Create private GKE cluster
resource "google_container_cluster" "cluster" {
  name                     = "private-gke-cluster"
  location                 = "europe-west2-c" # London region
  remove_default_node_pool = true
  network                  = google_compute_network.vpc_network.self_link
  subnetwork               = google_compute_subnetwork.subnet.self_link
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28" # RFC1918 28-bit block
  }
  ip_allocation_policy {

  }
  initial_node_count = 3
}

# Create node pool within cluster
resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.cluster.name
  location   = "europe-west2-c"
  node_count = 3
  node_config {  
    preemptible     = false
    machine_type    = "e2-small"
    service_account = google_service_account.service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Create node pool within cluster
resource "google_container_node_pool" "general1" {
  name     = "general1"
  cluster  = google_container_cluster.cluster.name
  location = "europe-west2-c"
  autoscaling {
    min_node_count = 0
    max_node_count = 5
  }
  node_config {
    preemptible     = true
    machine_type    = "e2-small"
    service_account = google_service_account.service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
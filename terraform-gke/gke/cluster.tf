#####################################################################
# GKE Cluster
#####################################################################
resource "google_container_cluster" "google-cluster" {
  name               = "gke-cluster-terraform"
  zone               = "${var.zone}"
  remove_default_node_pool = true
  initial_node_count = 1

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

//  master_auth {
//    username = "admin"
//    password = "admin"
//  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/compute",
    ]
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "${var.zone}"
  cluster    = "${google_container_cluster.google-cluster.name}"
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "${var.cluster_machine_type}"

//    metadata {
//      disable-legacy-endpoints = "true"
//    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

#####################################################################
# Output for K8S
#####################################################################
output "client_certificate" {
  value     = "${google_container_cluster.google-cluster.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${google_container_cluster.google-cluster.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.google-cluster.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value     = "${google_container_cluster.google-cluster.endpoint}"
  sensitive = true
}
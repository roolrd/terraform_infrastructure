provider "google" {
  credentials = file("gcp_cred.json")
  project     = "development-292918"
  region      = "us-east1"
  zone        = "us-east1-d"
}

resource "google_container_cluster" "jenkins-cd" {
  name     = "jenkins-cd"
  location = "us-east1"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "jenkins_nodes" {
  name       = "jenkins-node-pool"
  location   = "us-east1"
  cluster    = google_container_cluster.jenkins-cd.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-1"

    service_account = "jenkins-sa@development-292918.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

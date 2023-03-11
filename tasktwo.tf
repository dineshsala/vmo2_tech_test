resource "google_service_account" "tester" {
  project      = "gcptask-380221"
  account_id = "tester"
}

resource "google_bigquery_dataset_iam_binding" "tester" {
  dataset_id = google_bigquery_dataset.vmo2_tech_test.dataset_id
  role = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.tester.email}",
  ]
}

resource "google_bigquery_dataset" "vmo2_tech_test" {
  dataset_id                  = "vmo2_tech_test"
  friendly_name               = "vmo2 tech dataset"
  description                 = "New dataset for VMO2 Tech Test"
  location                    = "EU"
  default_table_expiration_ms = "3600000" #onehour
}

resource "google_bigquery_dataset_access" "access" {
  dataset_id    = "vmo2_tech_test"
  project = var.project_id
  role          = "roles/bigquery.dataEditor"
  user_by_email = "dinesh.sala@gmail.com"
}


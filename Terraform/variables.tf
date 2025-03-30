variable "credentials" {
  description = "Credentials Google Cloud path"
  default     = "../keys/credentials.json"
}

variable "project" {
  description = "Project"
  default     = "lucid-defender-453519-p2"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "region" {
  description = "Region"
  default     = "us-central1"
}

variable "gcs_bucket_name" {
  description = "Storage Project Bucket Name"
  default     = "lucid-defender-453519-p2-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}
# ──────────────────────────────────────────────────────────────
# Trelea Website — Terraform Variables
# ──────────────────────────────────────────────────────────────

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "spaces_access_id" {
  description = "DO Spaces access key ID"
  type        = string
  sensitive   = true
}

variable "spaces_secret_key" {
  description = "DO Spaces secret key"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repo for trelea.com static site (owner/repo)"
  type        = string
}

variable "github_branch" {
  description = "Git branch for deploys"
  type        = string
  default     = "main"
}

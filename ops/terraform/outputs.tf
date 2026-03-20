# ──────────────────────────────────────────────────────────────
# Outputs
# ──────────────────────────────────────────────────────────────

output "app_id" {
  description = "App Platform app ID"
  value       = digitalocean_app.trelea.id
}

output "app_url" {
  description = "App Platform default URL"
  value       = digitalocean_app.trelea.live_url
}

output "url" {
  description = "trelea.com website URL"
  value       = "https://trelea.com"
}

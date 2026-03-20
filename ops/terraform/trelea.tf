# ──────────────────────────────────────────────────────────────
# trelea.com — Static Site on DO App Platform (free tier)
# ──────────────────────────────────────────────────────────────
#
# Architecture:
#   - App Platform serves static site (free tier, handles apex + www)
#   - Auto-SSL via Let's Encrypt
#   - Source: GitHub repo (root directory)
#   - Email via Google Workspace (MX records)
#
# Prerequisites:
#   - Install the DigitalOcean GitHub App in your GitHub account
#     (DO Console → Apps → Create App → GitHub → Install & Authorize)
#   - Set var.github_repo to "owner/repo-name"
#
# Deploy: push to main branch (auto-deploy), or:
#   doctl apps create-deployment <app-id>
# ──────────────────────────────────────────────────────────────

# ── App Platform Static Site ──

resource "digitalocean_app" "trelea" {
  spec {
    name   = "trelea-website"
    region = "sfo" # App Platform uses short region slugs

    static_site {
      name             = "website"
      index_document   = "index.html"
      error_document   = "index.html"
      source_dir       = "/"
      output_dir       = "/"

      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = false
      }
    }

    domain {
      name = "trelea.com"
      type = "PRIMARY"
    }

    domain {
      name = "www.trelea.com"
      type = "ALIAS"
    }
  }
}

# ── DNS — Domain ──

resource "digitalocean_domain" "trelea" {
  name = "trelea.com"
}

# ── DNS — Web Records ──
#
# App Platform provides its own ingress. For custom domains:
#   - Root domain: A record pointing to App Platform's IP
#   - www: CNAME to the app's default hostname
#
# After first `terraform apply`:
#   1. Go to DO Console → Apps → trelea-website → Settings → Domains
#   2. Copy the A record IP shown for "trelea.com"
#   3. Update the A record values below
#   4. Run `terraform apply` again to create DNS records
#
# DO auto-provisions SSL once DNS propagates.

resource "digitalocean_record" "trelea_root_1" {
  domain = digitalocean_domain.trelea.id
  type   = "A"
  name   = "@"
  value  = "162.159.140.98"
  ttl    = 300
}

resource "digitalocean_record" "trelea_root_2" {
  domain = digitalocean_domain.trelea.id
  type   = "A"
  name   = "@"
  value  = "172.66.0.96"
  ttl    = 300
}

resource "digitalocean_record" "trelea_www" {
  domain = digitalocean_domain.trelea.id
  type   = "CNAME"
  name   = "www"
  value  = "${replace(digitalocean_app.trelea.default_ingress, "https://", "")}."
  ttl    = 300
}

# ── DNS — Email (Google Workspace) ──

resource "digitalocean_record" "trelea_mx1" {
  domain   = digitalocean_domain.trelea.id
  type     = "MX"
  name     = "@"
  value    = "aspmx.l.google.com."
  priority = 1
  ttl      = 3600
}

resource "digitalocean_record" "trelea_mx2" {
  domain   = digitalocean_domain.trelea.id
  type     = "MX"
  name     = "@"
  value    = "alt1.aspmx.l.google.com."
  priority = 5
  ttl      = 3600
}

resource "digitalocean_record" "trelea_mx3" {
  domain   = digitalocean_domain.trelea.id
  type     = "MX"
  name     = "@"
  value    = "alt2.aspmx.l.google.com."
  priority = 5
  ttl      = 3600
}

resource "digitalocean_record" "trelea_mx4" {
  domain   = digitalocean_domain.trelea.id
  type     = "MX"
  name     = "@"
  value    = "alt3.aspmx.l.google.com."
  priority = 10
  ttl      = 3600
}

resource "digitalocean_record" "trelea_mx5" {
  domain   = digitalocean_domain.trelea.id
  type     = "MX"
  name     = "@"
  value    = "alt4.aspmx.l.google.com."
  priority = 10
  ttl      = 3600
}

# ── DNS — Google Workspace SPF ──

resource "digitalocean_record" "trelea_spf" {
  domain = digitalocean_domain.trelea.id
  type   = "TXT"
  name   = "@"
  value  = "v=spf1 include:_spf.google.com ~all"
  ttl    = 3600
}

# ── DNS — Google Verification ──

resource "digitalocean_record" "trelea_google_verify_txt" {
  domain = digitalocean_domain.trelea.id
  type   = "TXT"
  name   = "@"
  value  = "google-site-verification=_Mhz3sXzOh-A21lHZoWVA37MoIKl_MLdEy_URfzXoYI"
  ttl    = 300
}

resource "digitalocean_record" "trelea_google_verify_cname" {
  domain = digitalocean_domain.trelea.id
  type   = "CNAME"
  name   = "cf5o5qwxvkwb"
  value  = "gv-umnzvobvoog4y5.dv.googlehosted.com."
  ttl    = 300
}

# ── DNS — Google Workspace DKIM ──

resource "digitalocean_record" "trelea_google_dkim" {
  domain = digitalocean_domain.trelea.id
  type   = "TXT"
  name   = "google._domainkey"
  value  = "v=DKIM1;k=rsa;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsFSGufU+NIybmEwYJGHXOBM3uVISgK4WttlGBnQ3g1Y6h84wNkcFZH8MAililhL8ZSjy9CGDXWzRmaRaeNJla3IHqSyFlSDQIK/tj8QQ9iheZbo3qyqBYejoY8ArYm507LQyF3IpR6xMXaYwpva4dtPsU0DKXONoWFknUucuUvK7TJo0JxujeuTsinfYth6E8/umgeEQ+4QWyES8EOaj/l9PvuNYnPrDNTyBmxbMGVq6c8/PVrBZQyDm3nnw9X2SYLcJgnAU9g7imjYtFykFBXQyUbn4b4I60wwKsiIAUIR5SlLWGS41vOO8OWwnDybGW/Mv0WrRVFahqzMk5+ptMwIDAQAB"
  ttl    = 300
}

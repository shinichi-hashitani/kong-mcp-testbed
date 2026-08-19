# MCP Inspector が利用するOAuthクライアント。
# ローカルのデモツールでクライアントシークレットを安全に保持できないため、
# PKCE前提のパブリッククライアント(SPA)として作成する。
resource "auth0_client" "mcp_inspector" {
  name            = "Kong MCP Inspector"
  app_type        = "spa"
  oidc_conformant = true
  callbacks       = var.mcp_inspector_callback_urls
  grant_types     = ["authorization_code", "refresh_token"]

  jwt_configuration {
    alg = "RS256"
  }
}

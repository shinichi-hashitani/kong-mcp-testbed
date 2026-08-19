output "auth0_issuer" {
  description = "decK yaml の DECK_AUTH0_ISSUER に設定する値。"
  value       = "https://${var.auth0_domain}/"
}

output "mcp_inspector_client_id" {
  description = "MCP InspectorのOAuth設定画面に入力するClient ID。"
  value       = auth0_client.mcp_inspector.client_id
}

output "mcp_resource_identifier" {
  description = "Kong側 ai-mcp-oauth2 の config.resource と一致させる値(確認用)。"
  value       = var.mcp_resource_identifier
}

output "test_user_emails" {
  description = "作成したテストユーザーのメールアドレス一覧(ログイン確認用)。"
  value       = { for k, v in auth0_user.test_user : k => v.email }
}

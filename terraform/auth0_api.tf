# Kong の ai-mcp-oauth2 プラグインが検証するアクセストークンの発行元API(Resource Server)。
# identifier は Kong 側 config.resource / MCPクライアントがトークン要求時に指定する
# audience/resource と一致させる必要がある。
resource "auth0_resource_server" "mcp_api" {
  name        = "Kong MCP Testbed"
  identifier  = var.mcp_resource_identifier
  signing_alg = "RS256"
}

variable "auth0_domain" {
  description = "Auth0テナントのドメイン (例: dev-xxxxxxx.us.auth0.com)。手動で作成したテナントのものを指定。"
  type        = string
}

variable "auth0_terraform_client_id" {
  description = "Terraformが利用するM2Mアプリケーション(Management API権限付与済み)のClient ID。Auth0ダッシュボードで手動作成したものを指定。"
  type        = string
}

variable "auth0_terraform_client_secret" {
  description = "上記M2MアプリケーションのClient Secret。"
  type        = string
  sensitive   = true
}

variable "mcp_resource_identifier" {
  description = "MCPのresource識別子(=Auth0 APIのidentifier=アクセストークンのaudience)。Kong側 ai-mcp-oauth2 プラグインの config.resource と完全に一致させること。"
  type        = string
  default     = "http://localhost:8000/accounts/mcp"
}

variable "custom_claim_namespace" {
  description = "departmentカスタムクレームのネームスペース付きキー。OIDC仕様上、標準クレーム以外は絶対URIでの名前空間指定が必須。Kong側 access_token_claim_field の参照先と一致させること。"
  type        = string
  default     = "https://kong-mcp-testbed.example/department"
}

variable "mcp_inspector_callback_urls" {
  description = "MCP InspectorのOAuthコールバックURL一覧。"
  type        = list(string)
  default = [
    "http://localhost:6274/oauth/callback",
    "http://localhost:6274/oauth/callback/debug",
  ]
}

variable "test_users" {
  description = "テストユーザー定義。keyはユーザーの識別名、departmentの値がACL判定の主体(subject)としてそのまま使われる。"
  type = map(object({
    email      = string
    department = string
  }))
  default = {
    finance_user = {
      email      = "finance-user@example.com"
      department = "finance"
    }
    marketing_user = {
      email      = "marketing-user@example.com"
      department = "marketing"
    }
  }
}

variable "test_user_password" {
  description = "テストユーザー共通の初期パスワード(デモ用)。Auth0のパスワードポリシーを満たす値を指定。"
  type        = string
  sensitive   = true
}

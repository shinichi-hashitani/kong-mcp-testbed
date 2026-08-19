# ログイン成功時にuser_metadata.departmentをカスタムクレームとしてID/アクセストークンに注入する。
resource "auth0_action" "add_department_claim" {
  name    = "add-department-claim"
  runtime = "node18"
  deploy  = true

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  code = <<-EOT
    exports.onExecutePostLogin = async (event, api) => {
      const namespace = "${var.custom_claim_namespace}";
      const department = event.user.user_metadata && event.user.user_metadata.department;
      if (department) {
        api.idToken.setCustomClaim(namespace, department);
        api.accessToken.setCustomClaim(namespace, department);
      }
    };
  EOT
}

resource "auth0_trigger_actions" "post_login_flow" {
  trigger = "post-login"

  actions {
    id           = auth0_action.add_department_claim.id
    display_name = auth0_action.add_department_claim.name
  }
}

# 検証用の2ユーザー。department属性(user_metadata)がACL判定の主体となる。
resource "auth0_user" "test_user" {
  for_each = var.test_users

  connection_name = "Username-Password-Authentication"
  email           = each.value.email
  password        = var.test_user_password
  email_verified  = true

  user_metadata = jsonencode({
    department = each.value.department
  })
}

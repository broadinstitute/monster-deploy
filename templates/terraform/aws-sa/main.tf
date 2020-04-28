# Generate the new account.
resource aws_iam_user user {
  provider = aws.target
  name = var.account_id
}
resource aws_iam_access_key user_key {
  provider = aws.target
  user = aws_iam_user.user.name
}
resource vault_generic_secret user_secret {
  provider = vault.target
  path = var.vault_path
  data_json = <<DATA
{
  "access_key_id": "${aws_iam_access_key.user_key.id}",
  "secret_access_key": "${aws_iam_access_key.user_key.secret}"
}
DATA
}

# Add policies to the account.
data aws_iam_policy_document user_policy {
  dynamic "statement" {
    for_each = var.iam_policy
    content {
      sid = statement.value["subject_id"]
      actions = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}
resource aws_iam_user_policy user_policy {
  provider = aws.target
  name = "${var.account_id}-policy"
  policy = data.aws_iam_policy_document.user_policy.json
  user = aws_iam_user.user.name
}

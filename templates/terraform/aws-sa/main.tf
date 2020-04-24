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

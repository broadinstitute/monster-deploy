###
## Create buckets in two regions so we can test that our
## code doesn't break when using the non-default region.
###
resource "aws_s3_bucket" "s3_east_bucket" {
  provider = "aws.us-east-1"
  bucket = "monster-s3-us-east-1"
  region = "us-east-1"
}
resource "aws_s3_bucket" "s3_west_bucket" {
  provider = "aws.us-west-2"
  bucket = "monster-s3-us-west-2"
  region = "us-west-2"
}

###
## Create a machine user, and stash its access secrets in Vault
###
resource "aws_iam_user" "s3_transfer_user" {
  provider = "aws.us-east-1"
  name = "monster-s3-tester"
}
resource "aws_iam_access_key" "s3_transfer_user_key" {
  provider = "aws.us-east-1"
  user = aws_iam_user.s3_transfer_user.name
}
resource "vault_generic_secret" "s3_transfer_user_secret" {
  path = "secret/dsde/monster/dev/aws/s3-transfer-user"
  data_json = <<DATA
{
  "access_key_id": "${aws_iam_access_key.s3_transfer_user_key.id}",
  "access_secret_access_key": "${aws_iam_access_key.s3_transfer_user_key.secret}"
}
DATA
}

###
## Grant the machine user full access to the two test buckets.
###
data "aws_iam_policy_document" "s3_transfer_access_policy" {
  statement {
    sid = "ListObjects"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.s3_east_bucket.arn,
      aws_s3_bucket.s3_west_bucket.arn
    ]
  }
  statement {
    sid = "ObjectActions"
    actions = ["s3:*Object"]
    resources = [
      aws_s3_bucket.s3_east_bucket.arn,
      aws_s3_bucket.s3_west_bucket.arn
    ]
  }
}

resource "aws_iam_user_policy" "s3_transfer_access_policy" {
  provider = "aws.us-east-1"
  name = "MonsterS3TransferAccessPolicy"
  policy = data.aws_iam_policy_document.s3_transfer_access_policy.json
  user = aws_iam_user.s3_transfer_user.name
}

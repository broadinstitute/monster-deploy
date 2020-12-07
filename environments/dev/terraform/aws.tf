###
## Set up multiple AWS providers so we can stage
## test data in many regions.
###
provider aws {
  region = "us-east-1"
  alias = "us-east-1"
}
provider aws {
  region = "us-west-2"
  alias = "us-west-2"
}

###
## Create buckets in two regions so we can test that our
## code doesn't break when using the non-default region.
###
resource aws_s3_bucket s3_east_bucket {
  provider = aws.us-east-1
  bucket = "monster-s3-us-east-1"
  region = "us-east-1"
}
resource aws_s3_bucket s3_west_bucket {
  provider = aws.us-west-2
  bucket = "monster-s3-us-west-2"
  region = "us-west-2"
}

###
## Create a machine user, and stash its access secrets in Vault
###
module test_transfer_user {
  providers = {
    aws.target = aws.us-east-1
  }

  source = "../../../../templates/aws-sa"
  account_id = "monster-s3-tester"
  vault_path = "${local.vault_prefix}/aws/s3-transfer-user"

  iam_policy = [
    {
      subject_id = "ListObjects",
      actions = ["s3:ListBucket"],
      resources = [
        aws_s3_bucket.s3_east_bucket.arn,
        aws_s3_bucket.s3_west_bucket.arn
      ]
    },
    {
      subject_id = "ObjectActions",
      actions = ["s3:*Object"]
      resources = [
        "${aws_s3_bucket.s3_east_bucket.arn}/*",
        "${aws_s3_bucket.s3_west_bucket.arn}/*"
      ]
    }
  ]
}

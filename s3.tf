resource "aws_s3_bucket" "wordpress_s3_bucket" {
  bucket = "epam-wordpress-artifacts-bucket"
}

resource "aws_s3_bucket_public_access_block" "wordpress_s3_bpab" {
  bucket = aws_s3_bucket.wordpress_s3_bucket.id

  block_public_acls   = false
  block_public_policy = false
#  ignore_public_acls = true
}

resource "aws_s3_account_public_access_block" "wordpress_s3_ac_public_block" {
  block_public_acls   = false
  block_public_policy = false
}

resource "aws_datasync_location_s3" "wordpress_datasync_location_s3" {
  s3_bucket_arn = aws_s3_bucket.wordpress_s3_bucket.arn
  subdirectory  = "/"

  s3_config {
    bucket_access_role_arn = aws_iam_role.wp_iam_role_s3_dc.arn
  }
}

resource "aws_datasync_location_efs" "wordpress_datasync_location_efs" {
  efs_file_system_arn = aws_efs_mount_target.wp_efs_mnt_a.file_system_arn
  subdirectory  = "/"

  ec2_config {
    security_group_arns = [aws_security_group.wp_location_dc_security_group.arn]
    subnet_arn          = aws_subnet.wordpress_subnet_a.arn
  }
}

resource "aws_datasync_task" "wordpress_datasync" {
  destination_location_arn = aws_datasync_location_efs.wordpress_datasync_location_efs.arn
  name                     = "wordpress_datasync"
  source_location_arn      = aws_datasync_location_s3.wordpress_datasync_location_s3.arn

  options {
    bytes_per_second = -1
  }
}


resource "aws_security_group" "wp_location_dc_security_group" {
  name        = "allow_location_datasync"
  description = "Allow inbound traffic in 10.0.0.0/16"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    description      = "data sync location"
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "wp_efs_security_group"
  }
}

data "aws_iam_policy_document" "wp_s3_iam_policy" {

  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["datasync.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "wp_iam_role_s3_dc" {
    assume_role_policy = data.aws_iam_policy_document.wp_s3_iam_policy.json
    name = "wp_iam_role_s3_datasync_fullAcess"
}

resource "aws_iam_role_policy_attachment" "wp_iam_role_policy_attachment_s3_dc" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role = aws_iam_role.wp_iam_role_s3_dc.id

}

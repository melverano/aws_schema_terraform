resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = "wordpress_efs_token"

  tags = {
    Name    = "wordpress_efs"
    Project = "wordpress"
    Type    = "Storage"
  }
}

resource "aws_efs_mount_target" "wp_efs_mnt_a" {
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = aws_subnet.wordpress_subnet_a.id
  security_groups = [aws_security_group.wp_efs_security_group.id]
}

resource "aws_efs_mount_target" "wp_efs_mnt_b" {
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = aws_subnet.wordpress_subnet_b.id
  security_groups = [aws_security_group.wp_efs_security_group.id]
}

resource "aws_security_group" "wp_efs_security_group" {
  name        = "allow_nfs_port"
  description = "Allow inbound traffic in 10.0.0.0/16"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    description      = "nfs"
    protocol         = "tcp"
    from_port        = 2049
    to_port          = 2049
    cidr_blocks      = [aws_vpc.wordpress_vpc.cidr_block]
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

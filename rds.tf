resource "aws_db_instance" "wordpress-rds" {
  allocated_storage    = 15
  engine               = "mariadb"
  engine_version       = "10.2.11"
  instance_class       = "db.t2.micro"
  name                 = "wordpress"
  username             = "wordpress"
  password             = "lih98oqp61az"
  availability_zone    = "eu-central-1a"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.wp_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.wp_db_security_group.id]
}

resource "aws_db_subnet_group" "wp_db_subnet_group" {
  name       = "wp_db_subnet_group"
  subnet_ids = [aws_subnet.wordpress_subnet_a.id, aws_subnet.wordpress_subnet_b.id]

  tags = {
    Name    = "wordpress_db_subnet_group"
    Project = "wordpress"
    Type    = "RDS"
  }
}

resource "aws_security_group" "wp_db_security_group" {
  name        = "allow_mariad_db_port"
  description = "Allow inbound traffic in 10.0.0.0/16"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    description      = "mariaDB"
    protocol         = "tcp"
    from_port        = 3306
    to_port          = 3306
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
    Name = "wp_db_security_group"
  }
}

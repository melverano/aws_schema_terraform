resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name    = "wordpress_vpc"
    Project = "wordpress"
    Type    = "Network"
  }
}

resource "aws_subnet" "wordpress_subnet_a" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone_id    = "euc1-az2"
  map_public_ip_on_launch = true

  tags = {
    Name    = "wordpress_subnet_a"
    Project = "wordpress"
    Type    = "Network"
  }
}

resource "aws_subnet" "wordpress_subnet_b" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone_id    = "euc1-az3"
  map_public_ip_on_launch = true

  tags = {
    Name    = "wordpress_subnet_b"
    Project = "wordpress"
    Type    = "Network"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name    = "wordpress_igw"
    Project = "wordpress"
    Type    = "Network"
  }
}

resource "aws_route_table" "wordpress_route_table" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name    = "wordpress_route_table"
    Project = "wordpress"
    Type    = "Network"
  }
}

resource "aws_route_table_association" "wp_rta_a" {
  subnet_id      = aws_subnet.wordpress_subnet_a.id
  route_table_id = aws_route_table.wordpress_route_table.id
}

resource "aws_route_table_association" "wp_rta_b" {
  subnet_id      = aws_subnet.wordpress_subnet_b.id
  route_table_id = aws_route_table.wordpress_route_table.id
}

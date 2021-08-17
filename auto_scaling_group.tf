resource "aws_security_group" "wordpress_ec2_security_group" {
  name        = "allow_http"
  description = "Allow HTTP inbound connections"
  vpc_id = aws_vpc.wordpress_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress_ec2_security_group"
  }
}


resource "aws_launch_configuration" "wordpress_launch_cfg" {
  name_prefix = "wp-"
  image_id = "ami-0dc7b2d3a3627c91b" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name = "linux-key-ssh"
  security_groups = [aws_security_group.wordpress_ec2_security_group.id]
  associate_public_ip_address = true

  depends_on = [aws_efs_file_system.wordpress_efs]

  user_data = <<-EOF
  #!/bin/bash
  sudo mount -t efs ${aws_efs_file_system.wordpress_efs.id}:/ /var/www/
  EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "wp_elb_http_security_group" {
  name        = "wp_elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = aws_vpc.wordpress_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}

resource "aws_elb" "wordpress_elb" {
  name = "wordpress-elb"
  security_groups = [
    aws_security_group.wp_elb_http_security_group.id
  ]
  subnets = [
    aws_subnet.wordpress_subnet_a.id,
    aws_subnet.wordpress_subnet_b.id
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "TCP:80"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }

}

resource "aws_autoscaling_group" "wordpress_auto_scaling_group" {
  name = "${aws_launch_configuration.wordpress_launch_cfg.name}-asg"

  min_size             = 2
  desired_capacity     = 2
  max_size             = 4

  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.wordpress_elb.id
  ]

  launch_configuration = aws_launch_configuration.wordpress_launch_cfg.name

  vpc_zone_identifier  = [
    aws_subnet.wordpress_subnet_a.id,
    aws_subnet.wordpress_subnet_b.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "wordpress"
    propagate_at_launch = true
  }

}

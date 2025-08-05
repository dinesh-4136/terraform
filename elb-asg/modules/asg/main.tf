resource "aws_launch_template" "lt" {
  name_prefix   = "web-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups = [var.ec2_sg_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum install -y httpd
              echo "Hello from $(hostname)" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
            EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.subnets
  target_group_arns    = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
}

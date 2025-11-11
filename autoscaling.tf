# Launch Template
resource "aws_launch_template" "app" {
  name          = "csye6225_asg"
  image_id      = var.custom_ami_id != "" ? var.custom_ami_id : data.aws_ami.custom.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application.id]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2.arn
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    vpc_name       = var.vpc_name
    db_host        = aws_db_instance.csye6225.address
    db_name        = var.db_name
    db_user        = var.db_user
    s3_bucket_name = aws_s3_bucket.images.id
    aws_region     = var.aws_region
    sns_topic_arn  = aws_sns_topic.user_verification.arn
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.vpc_name}-web-application"
    }
  }

  depends_on = [
    aws_db_instance.csye6225,
    aws_secretsmanager_secret_version.db_password,
    aws_secretsmanager_secret_version.sendgrid_api_key
  ]
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                      = "${var.vpc_name}-asg"
  vpc_zone_identifier       = aws_subnet.public[*].id
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = var.asg_health_check_grace_period

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  default_cooldown = var.asg_cooldown

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  wait_for_capacity_timeout = "0"

  tag {
    key                 = "Name"
    value               = "${var.vpc_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.vpc_name
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb.app,
    aws_lb_target_group.app
  ]
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.vpc_name}-scale-up-policy"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.asg_cooldown
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.vpc_name}-scale-down-policy"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.asg_cooldown
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# CloudWatch Alarm for Scale Up
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.vpc_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.scale_up_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization and scales up if > ${var.scale_up_cpu_threshold}%"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# CloudWatch Alarm for Scale Down
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.vpc_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.scale_down_cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization and scales down if < ${var.scale_down_cpu_threshold}%"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}
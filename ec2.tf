# Data source to get the latest custom AMI
data "aws_ami" "custom" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["csye6225-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# EC2 Instance
resource "aws_instance" "web_application" {
  ami                    = var.custom_ami_id != "" ? var.custom_ami_id : data.aws_ami.custom.id
  instance_type          = var.instance_type
  subnet_id              = values(aws_subnet.public)[0].id
  vpc_security_group_ids = [aws_security_group.application.id]
  key_name               = var.key_name

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  }))

  tags = {
    Name = "${var.vpc_name}-web-application"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}
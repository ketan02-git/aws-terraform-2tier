data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "secure-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.ec2_sg]

  user_data = base64encode(<<-EOF
#!/bin/bash
apt update -y
apt install nginx -y

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat <<HTML > /var/www/html/index.html
<h1>Secure 2-Tier AWS Architecture</h1>
<p><b>Environment:</b> Production</p>
<p><b>Instance ID:</b> $INSTANCE_ID</p>
<p><b>Private IP:</b> $PRIVATE_IP</p>
<p><b>Availability Zone:</b> $AZ</p>
<p><b>Auto Scaling:</b> Enabled</p>
<p><b>Deployment:</b> GitHub Actions</p>
HTML

systemctl restart nginx
EOF
  )
}

resource "aws_autoscaling_group" "this" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]
}
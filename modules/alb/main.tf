resource "aws_lb" "this" {
  name               = "secure-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "this" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
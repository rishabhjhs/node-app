resource "aws_lb" "app_load_balancer" {
  name = "applb"
  internal = false
  load_balancer_type = "application"
  subnets = module.vpc.subnet_ids
  security_groups = [aws_security_group.allow_http_lb.id]
  enable_deletion_protection = false
}


resource "aws_lb_listener" "app_load_balancer_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
  }
}

resource "aws_lb_target_group" "app_lb_tg" {
  name        = "app-lb-tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    interval = 5
    timeout  = 2
  }
}

resource "aws_security_group" "allow_http_lb" {
  name        = "allow_http_lb"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTP request from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_lb"
  }
}

resource "aws_security_group_rule" "allow_http_lb_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.allow_http_lb.id
  source_security_group_id = aws_security_group.ecs_container.id
}

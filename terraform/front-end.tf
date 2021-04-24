# Configure security groups:

resource "aws_security_group" "http-allowed-from-anywhere" {
  name   = "http-allowed-from-anywhere"
  vpc_id = aws_vpc.ThreeTierAppWilliam-Ohio.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http-allowed-from-anywhere"
  }
}

resource "aws_security_group" "http-allowed-from-vpcCidr" {
  name   = "http-allowed-from-vpcCidr"
  vpc_id = aws_vpc.ThreeTierAppWilliam-Ohio.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http-allowed-from-vpcCidr"
  }
}


# Ensure load balancer for front-end:

resource "aws_lb" "ThreeTierAppWilliam-frontEndLB" {
  name                             = "ThreeTierAppWilliam-frontEndLB"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.http-allowed-from-anywhere.id]
  subnets                          = aws_subnet.public.*.id
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  # Todo: add bucket for access logs.

  tags = {
    Name = "ThreeTierAppWilliam-frontEndLB"
    Env  = "Prod"
  }
}

resource "aws_lb_target_group" "ThreeTierAppWilliam-frontEndLB-target-group" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ThreeTierAppWilliam-Ohio.id
  slow_start  = 60 # 1 min warmup time for hosts.
  target_type = "instance"

  tags = {
    Name = "ThreeTierAppWilliam-frontEndLB-target-group"
    Env  = "Prod"
  }
}

resource "aws_lb_target_group_attachment" "front-end-server_az1-attachment" {
  target_group_arn = aws_lb_target_group.ThreeTierAppWilliam-frontEndLB-target-group.arn
  target_id        = aws_instance.front-end-server_az1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "front-end-server_az2-attachment" {
  target_group_arn = aws_lb_target_group.ThreeTierAppWilliam-frontEndLB-target-group.arn
  target_id        = aws_instance.front-end-server_az2.id
  port             = 80
}

resource "aws_lb_listener" "ThreeTierAppWilliam-frontEndLB-lb-listener" {
  load_balancer_arn = aws_lb.ThreeTierAppWilliam-frontEndLB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ThreeTierAppWilliam-frontEndLB-target-group.arn
  }

}

# Get id of our custom AMI:

data "aws_ami" "front-end-server-wl" {
  most_recent = true

  filter {
    name   = "name"
    values = ["front-end-server-wl-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

resource "aws_instance" "front-end-server_az1" {
  ami                     = data.aws_ami.front-end-server-wl.id
  instance_type           = var.frontend_server_type
  availability_zone       = var.availability_zones[0]
  disable_api_termination = false
  vpc_security_group_ids  = [aws_security_group.http-allowed-from-vpcCidr.id, aws_security_group.ssh-allowed-from-BastionHosts.id]
  subnet_id               = aws_subnet.private[0].id
  key_name                = aws_key_pair.ThreeTierAppWilliam-Ohio-bastion-key.key_name

  tags = {
    Name = "front-end-server_az1"
    Env  = "Prod"
  }
}

resource "aws_instance" "front-end-server_az2" {
  ami                     = data.aws_ami.front-end-server-wl.id
  instance_type           = var.frontend_server_type
  availability_zone       = var.availability_zones[1]
  disable_api_termination = false
  vpc_security_group_ids  = [aws_security_group.http-allowed-from-vpcCidr.id, aws_security_group.ssh-allowed-from-BastionHosts.id]
  subnet_id               = aws_subnet.private[1].id
  key_name                = aws_key_pair.ThreeTierAppWilliam-Ohio-bastion-key.key_name

  tags = {
    Name = "front-end-server_az2"
    Env  = "Prod"
  }
}

output "front-end-lb-dns-name" {
  value = aws_lb.ThreeTierAppWilliam-frontEndLB.dns_name
}
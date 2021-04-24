
# Configure security groups:

resource "aws_security_group" "ssh-allowed-from-BastionHosts" {
  name   = "ssh-allowed-from-BastionHosts"
  vpc_id = aws_vpc.ThreeTierAppWilliam-Ohio.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.BastionHosts_SecGrp.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-allowed-from-BastionHosts"
  }
}

resource "aws_security_group" "BastionHosts_SecGrp" {
  name        = "BastionHosts_SecGrp"
  description = "SSH access to bastion hosts."
  vpc_id      = aws_vpc.ThreeTierAppWilliam-Ohio.id

  ingress {
    description = "SSH access to bastion hosts."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.headquarters_public_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionHosts_SecGrp"
  }
}

# Bastion Host for each AZ:

# Dynamically fetch the AMI:
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "BastionHost_az1" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t3.micro"
  availability_zone       = var.availability_zones[0]
  disable_api_termination = false
  vpc_security_group_ids  = [aws_security_group.BastionHosts_SecGrp.id]
  subnet_id               = aws_subnet.public[0].id
  key_name                = aws_key_pair.ThreeTierAppWilliam-Ohio-bastion-key.key_name

  tags = {
    Name = "BastionHost_az1"
    Env  = "Prod"
  }
}

resource "aws_instance" "BastionHost_az2" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t3.micro"
  availability_zone       = var.availability_zones[1]
  disable_api_termination = false
  vpc_security_group_ids  = [aws_security_group.BastionHosts_SecGrp.id]
  subnet_id               = aws_subnet.public[1].id
  key_name                = aws_key_pair.ThreeTierAppWilliam-Ohio-bastion-key.key_name

  tags = {
    Name = "BastionHost_az2"
    Env  = "Prod"
  }
}

# Elastic IPs:

resource "aws_eip" "BastionHost_elastic_ip_az1" {
  instance = aws_instance.BastionHost_az1.id
  vpc      = true
}

resource "aws_eip" "BastionHost_elastic_ip_az2" {
  instance = aws_instance.BastionHost_az2.id
  vpc      = true
}

# SSH keys for bastion host:

resource "aws_key_pair" "ThreeTierAppWilliam-Ohio-bastion-key" {
  key_name   = "ThreeTierAppWilliam-Ohio-bastion-key"
  public_key = var.bastion_public_key
}
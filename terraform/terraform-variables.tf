variable "region" {
  default     = "us-east-2"
  type        = string
  description = "Region of the VPC"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list(any)
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  type        = list(any)
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-2a", "us-east-2b"]
  type        = list(any)
  description = "List of availability zones"
}

variable "headquarters_public_ip" {
  default     = "1.2.3.4/32" # Customize to your needs.
  type        = string
  description = "Public IP of corp headquarters."
}

variable "bastion_public_key" {
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC460fEKnQM1IQGxMTgJy4cySN4i8HeQpQHyBxgWgBu45wyYWa/5nT4TVXaRUG7YtU3LUjw0zyDNSeYLX14m2SZDHrD8syUVbo6Z9Oznd18ppLXLuJOQxaW73Z8y9lN3uhwW7TAdFKvxWE+A0AppW54iBQv9xH8q0/cXvPuC0MUw2dx57H6pXzVKHkqp/ZHz7Kk5vO+ge/IKWLoeqUz61YjGj4SyT7SATRPSZa48C0XnNugEanyUl2d+1ZRbi3of2lZopUXvFc+TakGuPA8SfYWLNP5jRW34lnDaCgPkX2RnQ6NG2dJ+KXuQSWmEqBx4idXJWU1oP8S4DGC+dAPEw9JfjXPViozsCvtY4qo7qgS2nZ70UWdNm1GSY6DqYNs5uZX7DyLGEFr2RFyq+2MPs90TS7utyfFuGHqha6KJthtE3/zdXuvCUb7gGjswlSjKbtuXk+ZWYY+k5AGSev7xXJVd5VqKwneHOWbrnayGhwcrvQcD9fyB5/7AenK0BqyIIV49hX5Vibxahck+i/U170gTtHaXinnutnoM6kScGdq3k+dKMsGMnnLTi8wqpfSbft2XVF4QVaw5jOYc+hxEq/v5Q9Cgcivh9wJQnna72Mj4mL/cY6RhduCkf0M0hKSNqcKJPP/roDf8Jxvl+HXhHeV0pS9o4PIzoA4Yn1M4NOO4Q== ThreeTierAppWilliam-Ohio-bastion-key"
  type        = string
  description = "Public key for accessing bastion hosts."
}

variable "frontend_server_type" {
  default     = "t3.micro"
  type        = string
  description = "Server type for front-end servers."
}
variable "from" {
  type = number
}

variable "to" {
  type = number
}

variable "sg_id" {
  type = string
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = var.from
  to_port           = var.to
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.sg_id # Attach rule to its security group
}
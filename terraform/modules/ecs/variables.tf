variable "execution_role_arn" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "service_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_listener_dep" {
  type = any
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "container_port" {
  type = number
}
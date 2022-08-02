variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "us-west-1"
}

variable "environment" {
  default = "stage"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}



variable "public_subnet_cidr_blocks" {
  description = "cidr blocks for public subnets."
  type        = list(string)
  default     = [
    "10.0.21.0/24",
    "10.0.22.0/24",
  ]
}


variable "private_subnet_cidr_blocks" {
  description = "cidr blocks for private subnets."
  type        = list(string)
  default     = [
    "10.0.11.0/24",
    "10.0.12.0/24",
  ]
}

variable "availability_zones" {
  description = "availability_zones"
  type        = list(string)
  default     = [
    "us-west-1a",
    "us-west-1b",
  ]
}

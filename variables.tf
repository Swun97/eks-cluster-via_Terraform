variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "kubernetes-vpc"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "public_subnet_az" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "ap-southeast-1a"
}

variable "public_subnet_name" {
  description = "Name tag for the public subnet"
  type        = string
  default     = "kubernetes-public-subnet"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "192.168.2.0/24"
}

variable "private_subnet_az" {
  description = "Availability zone for the private subnet"
  type        = string
  default     = "ap-southeast-1b"
}

variable "private_subnet_name" {
  description = "Name tag for the private subnet"
  type        = string
  default     = "kubernetes-private-subnet"
}

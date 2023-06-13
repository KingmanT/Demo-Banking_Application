variable "key_pair" {
type = string
default = "Ubuntu_EC2"
description = "Specifies the key pair to be used"
}
variable "public_subnet_1_cidr_region1" {
  description = "CIDR Block for Public Subnet 1"
  default     = "10.0.0.0/23"
}
variable "public_subnet_2_cidr_region1" {
  description = "CIDR Block for Public Subnet 2"
  default     = "10.0.2.0/23"
}

variable "public_subnet_1_cidr_region2" {
  description = "CIDR Block for Public Subnet 1"
  default     = "172.0.0.0/23"
}
variable "public_subnet_2_cidr_region2" {
  description = "CIDR Block for Public Subnet 2"
  default     = "172.0.2.0/23"
}

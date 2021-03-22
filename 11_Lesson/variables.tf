variable "project" {
  default = "base"
}

variable "cidr_blk" {
  default = "10.0.0.0/16"
}

variable "web_public_subnet_cidrs" {
  default = [
    "10.10.11.0/24",
    "10.10.12.0/24",
  ]
}
/*
variable "private_subnet_cidrs" {
  default = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24",
  ]
}
*/

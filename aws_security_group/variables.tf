
variable "sg_env" {
  description = "Please enter one of the next environment: 'develop', 'staging', 'prod'"
  default     = "develop"
}

variable "sg_vpc_id" {
  //default = "vpc-11111111111111"
}

variable "cidr_blk" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "allow_ports_list" {
  default = {
    "develop" = ["80", "8080", "443"]
    "staging" = ["80", "443"]
    "prod"    = ["80", "443"]
  }
}

variable "common_tags" {
  type = map
  default = {
    Owner       = "Ruslan Riznyk"
    Project     = "Galicia"
    Environment = "Testing"
  }
}


variable "unique_id" {
  
}

variable "vpc_id" {
  
}

variable "sg_allowed_cidr" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "database_name" {
  
}

variable "database_password" {
  
}

variable "database_username" {
  
}

variable "subnet_group_ids" {
  type = list(string)
  default = []
}

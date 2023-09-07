variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable availability_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable ec2_key_name {}
variable "public_key_location" {
  default = "~/.ssh/id_rsa.pub"
}
variable db_name {}
variable db_secret_id {}
variable stage {}
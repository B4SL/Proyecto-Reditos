variable "Regi" {
  type        = string
  default     = "us-east-1"
  description = "Región"
}


variable "Regi_sub" {
  type        = string
  default     = "us-east-1a"
  description = "Región 2"
}

variable "key_pair_name" {
  description = "Nombre del key pair para las instancias EC2"
  type        = string
}
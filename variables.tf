variable "host_os" {
  type = string
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "vm_image" {
  type    = string
  default = "18.04-LTS"
}

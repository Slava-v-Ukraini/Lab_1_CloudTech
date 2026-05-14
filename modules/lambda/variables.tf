variable "function_name" {
  description = "Назва Lambda функції"
  type        = string
}

variable "archive_path" {
  description = "Шлях до zip-архіву з кодом"
  type        = string
} 

variable "role_arn" { type = string }
variable "handler" { type = string }

variable "namespace" { 
  type    = string
  default = "my-project"
}
variable "stage" { 
  type    = string
  default = "dev"
}
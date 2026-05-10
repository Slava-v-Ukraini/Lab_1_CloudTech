variable "namespace" {
  type        = string
  description = "Префікс для іменування ресурсів (наприклад, lpnu)"
  default     = "lpnu"
}

variable "stage" {
  type        = string
  description = "Етап розгортання (наприклад, dev або prod)"
  default     = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
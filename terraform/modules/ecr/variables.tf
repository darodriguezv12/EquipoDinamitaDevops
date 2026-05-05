variable "repository_name" {
  description = "ECR repository name."
  type        = string
}

variable "max_untagged_images" {
  description = "Maximum untagged images retained."
  type        = number
}

variable "max_tagged_image_count" {
  description = "Maximum total images retained."
  type        = number
}

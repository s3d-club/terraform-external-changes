variable "path" {
  type = string

  description = <<-EOT
    The path of the calling module.
    EOT
}

variable "tags" {
  type = map(string)

  description = <<-EOT
    The tags that will be part of the output.
    EOT
}

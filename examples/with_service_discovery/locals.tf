locals {
  # Need to find a better way to do this if the task has multiple containers
  # Also, at this moment for successful testing the ecs app, user has to manually push a image to this ecr repo
  containers = [for container in var.containers : merge(container, { image_tag = "${module.ecr.repository_url}:0.0.1" })]
}

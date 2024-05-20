// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "ecs"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  type        = string
  default     = "us-east-2"
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {
    ecs_cluster = {
      name = "fargate"
    }
    ecs_sg = {
      name = "ecs-sg"
    }
    vpce_sg = {
      name = "vpce-sg"
    }
  }
}

### VPC related variables

variable "vpc_name" {
  type    = string
  default = "test-vpc-015935234"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet cidrs"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the VPC"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

### VPC Endpoints related variables
variable "interface_vpc_endpoints" {
  description = "List of VPC endpoints to be created"
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "gateway_vpc_endpoints" {
  description = "List of VPC endpoints to be created"
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "vpce_security_group" {
  description = "Default security group to be attached to all VPC endpoints"
  type = object({
    ingress_rules       = optional(list(string))
    ingress_cidr_blocks = optional(list(string))
    egress_rules        = optional(list(string))
    egress_cidr_blocks  = optional(list(string))
  })

  default = null
}

### ECS Cluster related variables
variable "container_insights_enabled" {
  description = "Whether to enable container Insights or not"
  type        = bool
  default     = true
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository to be created for the application"
  type        = string
  default     = "terratest-backend-3456"
}

variable "repo_force_delete" {
  description = "If true, terraform is able to delete the ECR that contains images"
  type        = bool
  default     = true
}

variable "aws_profile" {
  description = "AWS Profile to login to AWS to push to ECR Repo"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag for primary container"
  type        = string
  default     = "0.0.1"
}
### ECS Task related

variable "ecs_svc_sg" {
  description = "Security Group for the ECS Service. Allows traffic from the ALB Security group"
  type = object({
    ingress_rules            = optional(list(string))
    ingress_cidr_blocks      = optional(list(string))
    ingress_with_cidr_blocks = optional(list(map(string)))
    egress_rules             = optional(list(string))
    egress_cidr_blocks       = optional(list(string))
    egress_with_cidr_blocks  = optional(list(map(string)))
    ingress_with_sg          = optional(list(map(string)))
    egress_with_sg           = optional(list(map(string)))
  })
}

### ALB related variables
variable "alb_sg" {
  description = "Security Group for the ALB"
  type = object({
    description         = optional(string)
    ingress_rules       = optional(list(string))
    ingress_cidr_blocks = optional(list(string))
    egress_rules        = optional(list(string))
    egress_cidr_blocks  = optional(list(string))
  })
}

variable "target_groups" {
  description = "List of target groups for the ALB"
  type = list(object({
    # Need to use name_prefix instead of name as the lifecycle property create_before_destroy is set
    name_prefix      = optional(string, "albtg")
    backend_protocol = optional(string, "HTTP")
    backend_port     = optional(number, 80)
    target_type      = optional(string, "ip")
  }))
}

variable "load_balancer_type" {
  description = "The type of the load balancer. Default is 'application'"
  type        = string
  default     = "application"
}

variable "is_internal" {
  description = "Whether this load balancer is internal or public facing"
  type        = bool
  default     = true
}

variable "http_listeners" {
  description = "A list of http listeners"
  type = list(object({
    port        = number
    protocol    = string
    action_type = string
    redirect    = any
  }))
}

variable "https_listeners" {
  description = "A list of https listeners"
  type = list(object({
    port            = number
    protocol        = string
    target_port     = number
    ssl_policy      = string
    certificate_arn = string
  }))
}

variable "containers" {
  description = "A map of task definition containers"
  type = list(object({
    name                     = optional(string)
    image_tag                = optional(string)
    memory                   = optional(number, null)
    cpu                      = optional(number, 0)
    memory_reservation       = optional(number, null)
    readonly_root_filesystem = optional(bool, false)
    essential                = optional(bool, true)
    log_configuration        = optional(any, null)
    environment              = optional(map(string), {})
    port_mappings = optional(list(object({
      containerPort = number
      hostPort      = number
      protocol      = string
    })))
  }))
}

### ECS Task related variables

variable "ecs_launch_type" {
  description = "The launch type of the ECS service. Default is FARGATE"
  type        = string
  default     = "FARGATE"
}

variable "network_mode" {
  description = "The network_mode of the ECS service. Default is awsvpc"
  type        = string
  default     = "awsvpc"
}

variable "ignore_changes_task_definition" {
  description = "Lifecycle ignore policy for task definition"
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "If true, public IP will be assigned to this service task, else private IP"
  type        = bool
  default     = false
}

variable "ignore_changes_desired_count" {
  description = "Lifecycle ignore policy for desired_count. If true, terraform won't detect changes when desired_count is changed"
  type        = bool
  default     = true
}

variable "task_cpu" {
  description = "Amount of CPU to be allocated to the task"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Amount of Memory to be allocated to the task"
  type        = number
  default     = 1024
}
variable "health_check_grace_period_seconds" {
  type        = number
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers"
  default     = 0
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment"
  default     = 100
}

variable "deployment_maximum_percent" {
  type        = number
  description = "The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment"
  default     = 200
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running"
  default     = 1
}

variable "deployment_controller_type" {
  type        = string
  description = "Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS`"
  default     = "ECS"
}

variable "wait_for_steady_state" {
  type        = bool
  description = "If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing"
  default     = false
}

### Service Discovery related variables

variable "enable_service_discovery" {
  description = "If true, the service discovery is enabled for this ECS Service"
  type        = bool
  default     = false
}

variable "namespace_name" {
  description = "Name of the namespace to be created. Should be valid domain_name"
  type        = string
  default     = ""
}

variable "service_discovery_container_name" {
  description = "The container name used for service discovery. Should match the name in var.containers. Mandatory in case of multiple containers"
  type        = string
  default     = ""
}

variable "service_discovery_service_name" {
  description = "Name of the Service Discovery Service"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to attach to all resources"
  type        = map(string)
  default     = {}
}

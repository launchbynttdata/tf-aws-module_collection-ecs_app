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
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    alb = {
      name       = "alb"
      max_length = 31
    }
    alb_tg = {
      name       = "albtg"
      max_length = 31
    }
    ecs_task = {
      name       = "td"
      max_length = 60
    }
    ecs_service = {
      name       = "svc"
      max_length = 60
    }
    ecs_sg = {
      name       = "ecssg"
      max_length = 60
    }
    alb_sg = {
      name       = "albsg"
      max_length = 60
    }
    vpc = {
      name       = "vpc"
      max_length = 60
    }
    alb_http_listener = {
      name       = "http"
      max_length = 60
    }
    alb_https_listener = {
      name       = "https"
      max_length = 60
    }
    s3_logs = {
      name       = "logs"
      max_length = 63
    }
    s3_config = {
      name       = "conf"
      max_length = 63
    }
    acm = {
      name       = "acm"
      max_length = 60
    }
    task_exec_role = {
      name       = "exec-role"
      max_length = 60
    }
    task_role = {
      name       = "task-role"
      max_length = 60
    }
    task_exec_policy = {
      name       = "exec-plcy"
      max_length = 60
    }
    task_policy = {
      name       = "task-plcy"
      max_length = 60
    }
  }
}

### VPC related variables
variable "vpc_id" {
  description = "The VPC ID of the VPC where infrastructure will be provisioned"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = []
}

variable "subnet_mapping" {
  description = "A list of subnet mapping blocks describing subnets to attach to network load balancer"
  type        = list(map(string))
  default     = []
}

### ECS related variables
variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "ecs_svc_security_group" {
  description = "Security group for the Virtual Gateway ECS application. By default, it allows traffic from ALB on the app_port"
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

  default = null
}

### ALB related variables
variable "alb_sg" {
  description = "Security Group for the ALB. https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf"
  type = object({
    description              = optional(string)
    ingress_rules            = optional(list(string))
    ingress_cidr_blocks      = optional(list(string))
    egress_rules             = optional(list(string))
    egress_cidr_blocks       = optional(list(string))
    ingress_with_cidr_blocks = optional(list(map(string)))
    egress_with_cidr_blocks  = optional(list(map(string)))
  })
}

variable "target_groups" {
  description = <<EOT
    List of target groups for the ALB
    The health_check can accept the following keys
      - enabled, interval, port, path, healthy_threshold, unhealthy_threshold, timeout, protocol, matcher
  EOT
  type = list(object({
    # Need to use name_prefix instead of name as the lifecycle property create_before_destroy is set
    name_prefix      = optional(string, "albtg")
    backend_protocol = optional(string, "HTTP")
    backend_port     = optional(number, 80)
    target_type      = optional(string, "ip")
    health_check     = optional(map(string), {})
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

variable "http_tcp_listeners" {
  description = "List of HTTP TCP listeners"
  type = list(object({
    port        = number
    protocol    = string
    action_type = string
    redirect    = any
  }))
  default = []
}

variable "https_listeners" {
  description = "List of HTTPs listeners"
  type = list(object({
    port     = number
    protocol = string
    #certificate_arn = string
  }))
  default = []
}

variable "listener_ssl_policy_default" {
  description = "The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html)."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-0-2021-06"
}

variable "redirect_to_https" {
  description = "Whether all http traffic should be redirected to https. Valid only for ALB when https listeners are configured"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Whether to enable HTTP/2.0 on the Application Load Balancer (not NLB). Default is false"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Indicates whether cross zone load balancing should be enabled in application load balancers."
  type        = bool
  default     = false
}

variable "subject_alternate_names" {
  description = "Additional domain names to be added to the certificate created for ALB. Domain names must be FQDN."
  type        = list(string)
  default     = []
}

variable "alb_logs_bucket_id" {
  description = "S3 bucket ID for ALB logs"
  type        = string
  default     = ""
}

variable "alb_logs_bucket_prefix" {
  description = "S3 bucket prefix for ALB logs"
  type        = string
  default     = null
}

variable "dns_zone_name" {
  description = "Name of the  Route53 DNS Zone where custom DNS records will be created. Required if use_https_listeners=true"
  type        = string
  default     = ""
}

variable "private_zone" {
  description = "Whether the dns_zone_name provided above is a private or public hosted zone. Required if dns_zone_name is not empty"
  type        = string
  default     = ""
}

variable "print_container_json" {
  description = "Print the container JSON object as output. Useful for debugging"
  type        = bool
  default     = false
}
variable "app_environment" {
  description = "Environment variables to be injected into the application containers"
  type        = map(string)
  default     = {}
}

variable "app_secrets" {
  description = "Secrets to be injected into the application containers. Map of secret Manager ARNs"
  type        = map(string)
  default     = {}
}

variable "app_image" {
  description = "Image to be used for the application container"
  type        = string
}

variable "containers" {
  description = "Specifications for containers to be launched in ECS for this task"
  type = list(object({
    name                     = string
    command                  = optional(list(string), [])
    essential                = optional(bool, false)
    cpu                      = optional(number, 0)
    memory                   = optional(number, null)
    memory_reservation       = optional(number, null)
    readonly_root_filesystem = optional(bool, false)
    environment              = optional(map(string), null)
    secrets                  = optional(map(string), null)
    mount_points = optional(list(object({
      containerPath = optional(string)
      readOnly      = optional(bool, false)
      sourceVolume  = optional(string)
    })), [])
    port_mappings = optional(list(object({
      containerPort = number
      hostPort      = optional(number)
      protocol      = optional(string, "tcp")
    })), [])
    healthcheck = optional(object({
      retries     = number
      command     = list(string)
      timeout     = number
      interval    = number
      startPeriod = number
    }), null)
    user = optional(string, null)
    container_depends_on = optional(list(object({
      containerName = string
      condition     = string
    })), [])
    log_configuration = optional(object({
      logDriver = optional(string, "awslogs")
      options = object({
        awslogs-group         = string
        awslogs-region        = string
        awslogs-create-group  = optional(string, "true")
        awslogs-stream-prefix = string
      })
    }), null)
  }))
  default = []
}

### ECS Task related variables
variable "otel_config_file_name" {
  description = "OpenTelemetry Configuration file name"
  type        = string
  default     = ""
}

variable "bind_mount_volumes" {
  description = "Extra bind mount volumes to be created for this task"
  type        = list(object({ name = string }))
  default     = []
}

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
  description = "Lifecycle ignore policy for task definition. If true, terraform won't detect changes when task_definition is changed outside of terraform"
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "If true, public IP will be assigned to this service task, else private IP"
  type        = bool
  default     = false
}

variable "ignore_changes_desired_count" {
  description = "Lifecycle ignore policy for desired_count. If true, terraform won't detect changes when desired_count is changed outside of terraform"
  type        = bool
  default     = true
}

variable "task_cpu" {
  description = "Amount of CPU to be allocated to the task"
  type        = string
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

variable "redeploy_on_apply" {
  description = "Redeploys the service everytime a terraform apply is executed. force_new_deployment should also be true for this flag to work"
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service when terraform apply is executed."
  type        = bool
  default     = false
}

variable "enable_service_discovery" {
  description = "If true, the service discovery is enabled for this ECS Service"
  type        = bool
  default     = false
}

variable "service_discovery_container_name" {
  description = "The container name used for service discovery. Should match the name in var.containers. Mandatory in case of multiple containers"
  type        = string
  default     = ""
}

variable "cloud_map_namespace_id" {
  description = "Cloud Map Namespace ID"
  type        = string
  default     = ""
}

variable "service_discovery_service_name" {
  description = "Name of the Service Discovery Service"
  type        = string
  default     = ""
}

variable "ecs_exec_role_custom_policy_json" {
  description = "Custom policy to attach to ecs task execution role. Document must be valid json."
  type        = string
  default     = ""
}

variable "ecs_role_custom_policy_json" {
  description = "Custom policy to attach to ecs task role. Document must be valid json."
  type        = string
  default     = ""
}

variable "create_config_bucket" {
  description = "Whether to create a config s3 bucket to store configurations"
  type        = bool
  default     = false
}

variable "config_objects" {
  description = "A map of objects to be created in config_bucket, where key is the object key in s3 bucket and value is the path of the file"
  type        = map(string)
  default     = {}
}

variable "kms_s3_key_arn" {
  description = "ARN of the AWS S3 key used for the config S3 bucket encryption"
  type        = string
  default     = ""
}

variable "runtime_platform" {
  type        = list(map(string))
  description = <<-EOT
    Zero or one runtime platform configurations that containers in your task may use.
    Map of strings with optional keys `operating_system_family` and `cpu_architecture`.
    See `runtime_platform` docs https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#runtime_platform
    EOT
  default     = []
}


variable "tags" {
  description = "A map of custom tags to be associated with the provisioned infrastructures."
  type        = map(string)
  default     = {}
}

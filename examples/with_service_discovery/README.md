# ECS Application with service discovery
This module will provision a ECS Service for a corresponding application. It will provision all dependent resources like
- VPC
- Platform Module
- ECS Service and Task Definition
- ALB and target Group
- Security Groups

**Note:** Currently, user needs to push a docker image manually to the ECR repo created by this module, post which the ECS Service can be successfully tested

## Pre-requisites
- Need to create a `provider.tf` with below contents
    ```
    provider "aws" {
      profile = "<profile-name>"
      region  = "<aws-region>"
    }
    ```
- Command to execute the module
  `terraform apply -var-file test.tfvars`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, <= 1.5.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.49.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.1.1 |
| <a name="module_ecs_platform"></a> [ecs\_platform](#module\_ecs\_platform) | git::https://github.com/launchbynttdata/tf-aws-module_collection-ecs_platform.git | 1.0.0 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | terraform-aws-modules/ecr/aws | ~> 1.6.0 |
| <a name="module_ecs_app"></a> [ecs\_app](#module\_ecs\_app) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_data.ecr_push](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"ecs"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "ecs_cluster": {<br>    "name": "fargate"<br>  },<br>  "ecs_sg": {<br>    "name": "ecs-sg"<br>  },<br>  "vpce_sg": {<br>    "name": "vpce-sg"<br>  }<br>}</pre> | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | n/a | `string` | `"test-vpc-015935234"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"10.1.0.0/16"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet cidrs | `list(string)` | <pre>[<br>  "10.1.1.0/24",<br>  "10.1.2.0/24",<br>  "10.1.3.0/24"<br>]</pre> | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for the VPC | `list(string)` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> | no |
| <a name="input_interface_vpc_endpoints"></a> [interface\_vpc\_endpoints](#input\_interface\_vpc\_endpoints) | List of VPC endpoints to be created | <pre>map(object({<br>    service_name        = string<br>    subnet_names        = optional(list(string), [])<br>    private_dns_enabled = optional(bool, false)<br>    tags                = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_gateway_vpc_endpoints"></a> [gateway\_vpc\_endpoints](#input\_gateway\_vpc\_endpoints) | List of VPC endpoints to be created | <pre>map(object({<br>    service_name        = string<br>    subnet_names        = optional(list(string), [])<br>    private_dns_enabled = optional(bool, false)<br>    tags                = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_vpce_security_group"></a> [vpce\_security\_group](#input\_vpce\_security\_group) | Default security group to be attached to all VPC endpoints | <pre>object({<br>    ingress_rules       = optional(list(string))<br>    ingress_cidr_blocks = optional(list(string))<br>    egress_rules        = optional(list(string))<br>    egress_cidr_blocks  = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_container_insights_enabled"></a> [container\_insights\_enabled](#input\_container\_insights\_enabled) | Whether to enable container Insights or not | `bool` | `true` | no |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | The name of the ECR repository to be created for the application | `string` | `"terratest-backend-3456"` | no |
| <a name="input_repo_force_delete"></a> [repo\_force\_delete](#input\_repo\_force\_delete) | If true, terraform is able to delete the ECR that contains images | `bool` | `true` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile to login to AWS to push to ECR Repo | `string` | n/a | yes |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Docker image tag for primary container | `string` | `"0.0.1"` | no |
| <a name="input_ecs_svc_sg"></a> [ecs\_svc\_sg](#input\_ecs\_svc\_sg) | Security Group for the ECS Service. Allows traffic from the ALB Security group | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>    ingress_with_sg          = optional(list(map(string)))<br>    egress_with_sg           = optional(list(map(string)))<br>  })</pre> | n/a | yes |
| <a name="input_alb_sg"></a> [alb\_sg](#input\_alb\_sg) | Security Group for the ALB | <pre>object({<br>    description         = optional(string)<br>    ingress_rules       = optional(list(string))<br>    ingress_cidr_blocks = optional(list(string))<br>    egress_rules        = optional(list(string))<br>    egress_cidr_blocks  = optional(list(string))<br>  })</pre> | n/a | yes |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | List of target groups for the ALB | <pre>list(object({<br>    # Need to use name_prefix instead of name as the lifecycle property create_before_destroy is set<br>    name_prefix      = optional(string, "albtg")<br>    backend_protocol = optional(string, "HTTP")<br>    backend_port     = optional(number, 80)<br>    target_type      = optional(string, "ip")<br>  }))</pre> | n/a | yes |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of the load balancer. Default is 'application' | `string` | `"application"` | no |
| <a name="input_is_internal"></a> [is\_internal](#input\_is\_internal) | Whether this load balancer is internal or public facing | `bool` | `true` | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | A list of http listeners | <pre>list(object({<br>    port        = number<br>    protocol    = string<br>    action_type = string<br>    redirect    = any<br>  }))</pre> | n/a | yes |
| <a name="input_https_listeners"></a> [https\_listeners](#input\_https\_listeners) | A list of https listeners | <pre>list(object({<br>    port            = number<br>    protocol        = string<br>    target_port     = number<br>    ssl_policy      = string<br>    certificate_arn = string<br>  }))</pre> | n/a | yes |
| <a name="input_containers"></a> [containers](#input\_containers) | A map of task definition containers | <pre>list(object({<br>    name                     = optional(string)<br>    image_tag                = optional(string)<br>    memory                   = optional(number, null)<br>    cpu                      = optional(number, 0)<br>    memory_reservation       = optional(number, null)<br>    readonly_root_filesystem = optional(bool, false)<br>    essential                = optional(bool, true)<br>    log_configuration        = optional(any, null)<br>    environment              = optional(map(string), {})<br>    port_mappings = optional(list(object({<br>      containerPort = number<br>      hostPort      = number<br>      protocol      = string<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | The launch type of the ECS service. Default is FARGATE | `string` | `"FARGATE"` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The network\_mode of the ECS service. Default is awsvpc | `string` | `"awsvpc"` | no |
| <a name="input_ignore_changes_task_definition"></a> [ignore\_changes\_task\_definition](#input\_ignore\_changes\_task\_definition) | Lifecycle ignore policy for task definition | `bool` | `true` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | If true, public IP will be assigned to this service task, else private IP | `bool` | `false` | no |
| <a name="input_ignore_changes_desired_count"></a> [ignore\_changes\_desired\_count](#input\_ignore\_changes\_desired\_count) | Lifecycle ignore policy for desired\_count. If true, terraform won't detect changes when desired\_count is changed | `bool` | `true` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Amount of CPU to be allocated to the task | `number` | `512` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Amount of Memory to be allocated to the task | `number` | `1024` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers | `number` | `0` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment | `number` | `100` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment | `number` | `200` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_deployment_controller_type"></a> [deployment\_controller\_type](#input\_deployment\_controller\_type) | Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS` | `string` | `"ECS"` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing | `bool` | `false` | no |
| <a name="input_enable_service_discovery"></a> [enable\_service\_discovery](#input\_enable\_service\_discovery) | If true, the service discovery is enabled for this ECS Service | `bool` | `false` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | Name of the namespace to be created. Should be valid domain\_name | `string` | `""` | no |
| <a name="input_service_discovery_container_name"></a> [service\_discovery\_container\_name](#input\_service\_discovery\_container\_name) | The container name used for service discovery. Should match the name in var.containers. Mandatory in case of multiple containers | `string` | `""` | no |
| <a name="input_service_discovery_service_name"></a> [service\_discovery\_service\_name](#input\_service\_discovery\_service\_name) | Name of the Service Discovery Service | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to attach to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interface_vpc_endpoints"></a> [interface\_vpc\_endpoints](#output\_interface\_vpc\_endpoints) | n/a |
| <a name="output_gateway_vpc_endpoints"></a> [gateway\_vpc\_endpoints](#output\_gateway\_vpc\_endpoints) | n/a |
| <a name="output_vpce_sg_id"></a> [vpce\_sg\_id](#output\_vpce\_sg\_id) | n/a |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | n/a |
| <a name="output_ecr_url"></a> [ecr\_url](#output\_ecr\_url) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
| <a name="output_alb_dns"></a> [alb\_dns](#output\_alb\_dns) | n/a |
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | n/a |
| <a name="output_alb_target_group_arn"></a> [alb\_target\_group\_arn](#output\_alb\_target\_group\_arn) | n/a |
| <a name="output_alb_target_group_name"></a> [alb\_target\_group\_name](#output\_alb\_target\_group\_name) | n/a |
| <a name="output_service_discovery_service_id"></a> [service\_discovery\_service\_id](#output\_service\_discovery\_service\_id) | n/a |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | n/a |
| <a name="output_namespace_hosted_zone"></a> [namespace\_hosted\_zone](#output\_namespace\_hosted\_zone) | n/a |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | n/a |
| <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn) | n/a |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | n/a |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | n/a |
| <a name="output_s3_logs_arn"></a> [s3\_logs\_arn](#output\_s3\_logs\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

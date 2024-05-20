# tf-aws-module_collection-ecs_app

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This module is a reference architecture terraform module that will provision a ECS service with all its dependencies in a provided ECS Cluster.

**Note**: Currently because of a bug with the provider, it is not possible to use terraform to perform `redeploy` on the ECS Service. The bug https://github.com/hashicorp/terraform-provider-aws/issues/28070 restricts users to enable the flag `force_new_deployement` on the terraform module. Hence, for now we can use this module to deploy the application to ECS Service for the first time but all the subsequent deployments needs to be performed some other way (using AWS CLI is one option).
## Usage
A sample variable file `example.tfvars` is available in the root directory which can be used to test this module. User needs to follow the below steps to execute this module
1. Update the `example.tfvars` to manually enter values for all fields marked within `<>` to make the variable file usable
2. Create a file `provider.tf` with the below contents
   ```
    provider "aws" {
      profile = "<profile_name>"
      region  = "<region_name>"
    }
    ```
   If using `SSO`, make sure you are logged in `aws sso login --profile <profile_name>`
3. Make sure terraform binary is installed on your local. Use command `type terraform` to find the installation location. If you are using `asdf`, you can run `asfd install` and it will install the correct terraform version for you. `.tool-version` contains all the dependencies.
4. Run the `terraform` to provision infrastructure on AWS
    ```
    # Initialize
    terraform init
    # Plan
    terraform plan -var-file example.tfvars
    # Apply (this is create the actual infrastructure)
    terraform apply -var-file example.tfvars -auto-approve
   ```
## Known Issues
1. When `force_new_deployment=true`, we get this error: https://github.com/hashicorp/terraform-provider-aws/issues/28070
2. Access Logs in ALB: https://github.com/hashicorp/terraform-provider-aws/issues/16674
## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `aws_env.sh` file on local workstation. Developer would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `aws` specific. If primitive/segment under development uses any other cloud provider than AWS, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "aws" {
  profile = "<profile_name>"
  region  = "<region_name>"
}
```

- A file named `terraform.tfvars` which contains key value pairs of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests
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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | git::https://github.com/launchbynttdata/tf-launch-module_library-resource_name.git | 1.0.0 |
| <a name="module_config_bucket"></a> [config\_bucket](#module\_config\_bucket) | git::https://github.com/launchbynttdata/tf-aws-module_collection-s3_bucket.git | 1.0.0 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.14.1 |
| <a name="module_s3_bucket_objects"></a> [s3\_bucket\_objects](#module\_s3\_bucket\_objects) | terraform-aws-modules/s3-bucket/aws//modules/object | 3.15.1 |
| <a name="module_sg_ecs_service"></a> [sg\_ecs\_service](#module\_sg\_ecs\_service) | terraform-aws-modules/security-group/aws | ~> 4.17.1 |
| <a name="module_sg_alb"></a> [sg\_alb](#module\_sg\_alb) | terraform-aws-modules/security-group/aws | ~> 4.17.1 |
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.3.2 |
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | ~> 8.7 |
| <a name="module_container_definitions"></a> [container\_definitions](#module\_container\_definitions) | git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git | 0.58.2 |
| <a name="module_service_discovery_service"></a> [service\_discovery\_service](#module\_service\_discovery\_service) | git::https://github.com/launchbynttdata/tf-aws-module_primitive-service_discovery_service.git | 1.0.0 |
| <a name="module_ecs_task_execution_policy"></a> [ecs\_task\_execution\_policy](#module\_ecs\_task\_execution\_policy) | cloudposse/iam-policy/aws | ~> 0.4.0 |
| <a name="module_ecs_task_policy"></a> [ecs\_task\_policy](#module\_ecs\_task\_policy) | cloudposse/iam-policy/aws | ~> 0.4.0 |
| <a name="module_ecs_alb_service_task"></a> [ecs\_alb\_service\_task](#module\_ecs\_alb\_service\_task) | cloudposse/ecs-alb-service-task/aws | ~> 0.67.1 |
| <a name="module_alb_dns_record"></a> [alb\_dns\_record](#module\_alb\_dns\_record) | git::https://github.com/launchbynttdata/tf-aws-module_primitive-dns_record.git | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"ecs"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br>    name       = string<br>    max_length = optional(number, 60)<br>  }))</pre> | <pre>{<br>  "acm": {<br>    "max_length": 60,<br>    "name": "acm"<br>  },<br>  "alb": {<br>    "max_length": 31,<br>    "name": "alb"<br>  },<br>  "alb_http_listener": {<br>    "max_length": 60,<br>    "name": "http"<br>  },<br>  "alb_https_listener": {<br>    "max_length": 60,<br>    "name": "https"<br>  },<br>  "alb_sg": {<br>    "max_length": 60,<br>    "name": "albsg"<br>  },<br>  "alb_tg": {<br>    "max_length": 31,<br>    "name": "albtg"<br>  },<br>  "ecs_service": {<br>    "max_length": 60,<br>    "name": "svc"<br>  },<br>  "ecs_sg": {<br>    "max_length": 60,<br>    "name": "ecssg"<br>  },<br>  "ecs_task": {<br>    "max_length": 60,<br>    "name": "td"<br>  },<br>  "s3_config": {<br>    "max_length": 63,<br>    "name": "conf"<br>  },<br>  "s3_logs": {<br>    "max_length": 63,<br>    "name": "logs"<br>  },<br>  "task_exec_policy": {<br>    "max_length": 60,<br>    "name": "exec-plcy"<br>  },<br>  "task_exec_role": {<br>    "max_length": 60,<br>    "name": "exec-role"<br>  },<br>  "task_policy": {<br>    "max_length": 60,<br>    "name": "task-plcy"<br>  },<br>  "task_role": {<br>    "max_length": 60,<br>    "name": "task-role"<br>  },<br>  "vpc": {<br>    "max_length": 60,<br>    "name": "vpc"<br>  }<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID of the VPC where infrastructure will be provisioned | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnets | `list(string)` | `[]` | no |
| <a name="input_subnet_mapping"></a> [subnet\_mapping](#input\_subnet\_mapping) | A list of subnet mapping blocks describing subnets to attach to network load balancer | `list(map(string))` | `[]` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of the ECS cluster | `string` | n/a | yes |
| <a name="input_ecs_svc_security_group"></a> [ecs\_svc\_security\_group](#input\_ecs\_svc\_security\_group) | Security group for the Virtual Gateway ECS application. By default, it allows traffic from ALB on the app\_port | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>    ingress_with_sg          = optional(list(map(string)))<br>    egress_with_sg           = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_alb_sg"></a> [alb\_sg](#input\_alb\_sg) | Security Group for the ALB. https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf | <pre>object({<br>    description              = optional(string)<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | n/a | yes |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | List of target groups for the ALB<br>    The health\_check can accept the following keys<br>      - enabled, interval, port, path, healthy\_threshold, unhealthy\_threshold, timeout, protocol, matcher | <pre>list(object({<br>    # Need to use name_prefix instead of name as the lifecycle property create_before_destroy is set<br>    name_prefix      = optional(string, "albtg")<br>    backend_protocol = optional(string, "HTTP")<br>    backend_port     = optional(number, 80)<br>    target_type      = optional(string, "ip")<br>    health_check     = optional(map(string), {})<br>  }))</pre> | n/a | yes |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of the load balancer. Default is 'application' | `string` | `"application"` | no |
| <a name="input_is_internal"></a> [is\_internal](#input\_is\_internal) | Whether this load balancer is internal or public facing | `bool` | `true` | no |
| <a name="input_http_tcp_listeners"></a> [http\_tcp\_listeners](#input\_http\_tcp\_listeners) | List of HTTP TCP listeners | <pre>list(object({<br>    port        = number<br>    protocol    = string<br>    action_type = string<br>    redirect    = any<br>  }))</pre> | `[]` | no |
| <a name="input_https_listeners"></a> [https\_listeners](#input\_https\_listeners) | List of HTTPs listeners | <pre>list(object({<br>    port     = number<br>    protocol = string<br>    #certificate_arn = string<br>  }))</pre> | `[]` | no |
| <a name="input_listener_ssl_policy_default"></a> [listener\_ssl\_policy\_default](#input\_listener\_ssl\_policy\_default) | The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html). | `string` | `"ELBSecurityPolicy-TLS13-1-0-2021-06"` | no |
| <a name="input_redirect_to_https"></a> [redirect\_to\_https](#input\_redirect\_to\_https) | Whether all http traffic should be redirected to https. Valid only for ALB when https listeners are configured | `bool` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Whether to enable HTTP/2.0 on the Application Load Balancer (not NLB). Default is false | `bool` | `false` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Indicates whether cross zone load balancing should be enabled in application load balancers. | `bool` | `false` | no |
| <a name="input_subject_alternate_names"></a> [subject\_alternate\_names](#input\_subject\_alternate\_names) | Additional domain names to be added to the certificate created for ALB. Domain names must be FQDN. | `list(string)` | `[]` | no |
| <a name="input_alb_logs_bucket_id"></a> [alb\_logs\_bucket\_id](#input\_alb\_logs\_bucket\_id) | S3 bucket ID for ALB logs | `string` | `""` | no |
| <a name="input_alb_logs_bucket_prefix"></a> [alb\_logs\_bucket\_prefix](#input\_alb\_logs\_bucket\_prefix) | S3 bucket prefix for ALB logs | `string` | `null` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Name of the  Route53 DNS Zone where custom DNS records will be created. Required if use\_https\_listeners=true | `string` | `""` | no |
| <a name="input_private_zone"></a> [private\_zone](#input\_private\_zone) | Whether the dns\_zone\_name provided above is a private or public hosted zone. Required if dns\_zone\_name is not empty | `string` | `""` | no |
| <a name="input_print_container_json"></a> [print\_container\_json](#input\_print\_container\_json) | Print the container JSON object as output. Useful for debugging | `bool` | `false` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Specifications for containers to be launched in ECS for this task | <pre>list(object({<br>    name                     = string<br>    image_tag                = string<br>    command                  = optional(list(string), [])<br>    essential                = optional(bool, false)<br>    cpu                      = optional(number, 0)<br>    memory                   = optional(number, null)<br>    memory_reservation       = optional(number, null)<br>    readonly_root_filesystem = optional(bool, false)<br>    environment              = optional(map(string), null)<br>    secrets                  = optional(map(string), null)<br>    mount_points = optional(list(object({<br>      containerPath = optional(string)<br>      readOnly      = optional(bool, false)<br>      sourceVolume  = optional(string)<br>    })), [])<br>    port_mappings = optional(list(object({<br>      containerPort = number<br>      hostPort      = optional(number)<br>      protocol      = optional(string, "tcp")<br>    })), [])<br>    healthcheck = optional(object({<br>      retries     = number<br>      command     = list(string)<br>      timeout     = number<br>      interval    = number<br>      startPeriod = number<br>    }), null)<br>    user = optional(string, null)<br>    container_depends_on = optional(list(object({<br>      containerName = string<br>      condition     = string<br>    })), [])<br>    log_configuration = optional(object({<br>      logDriver = optional(string, "awslogs")<br>      options = object({<br>        awslogs-group         = string<br>        awslogs-region        = string<br>        awslogs-create-group  = optional(string, "true")<br>        awslogs-stream-prefix = string<br>      })<br>    }), null)<br>  }))</pre> | `[]` | no |
| <a name="input_otel_config_file_name"></a> [otel\_config\_file\_name](#input\_otel\_config\_file\_name) | OpenTelemetry Configuration file name | `string` | `""` | no |
| <a name="input_bind_mount_volumes"></a> [bind\_mount\_volumes](#input\_bind\_mount\_volumes) | Extra bind mount volumes to be created for this task | `list(object({ name = string }))` | `[]` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | The launch type of the ECS service. Default is FARGATE | `string` | `"FARGATE"` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The network\_mode of the ECS service. Default is awsvpc | `string` | `"awsvpc"` | no |
| <a name="input_ignore_changes_task_definition"></a> [ignore\_changes\_task\_definition](#input\_ignore\_changes\_task\_definition) | Lifecycle ignore policy for task definition. If true, terraform won't detect changes when task\_definition is changed outside of terraform | `bool` | `true` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | If true, public IP will be assigned to this service task, else private IP | `bool` | `false` | no |
| <a name="input_ignore_changes_desired_count"></a> [ignore\_changes\_desired\_count](#input\_ignore\_changes\_desired\_count) | Lifecycle ignore policy for desired\_count. If true, terraform won't detect changes when desired\_count is changed outside of terraform | `bool` | `true` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Amount of CPU to be allocated to the task | `string` | `512` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Amount of Memory to be allocated to the task | `number` | `1024` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers | `number` | `0` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment | `number` | `100` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment | `number` | `200` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_deployment_controller_type"></a> [deployment\_controller\_type](#input\_deployment\_controller\_type) | Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS` | `string` | `"ECS"` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing | `bool` | `false` | no |
| <a name="input_redeploy_on_apply"></a> [redeploy\_on\_apply](#input\_redeploy\_on\_apply) | Redeploys the service everytime a terraform apply is executed. force\_new\_deployment should also be true for this flag to work | `bool` | `false` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service when terraform apply is executed. | `bool` | `false` | no |
| <a name="input_enable_service_discovery"></a> [enable\_service\_discovery](#input\_enable\_service\_discovery) | If true, the service discovery is enabled for this ECS Service | `bool` | `false` | no |
| <a name="input_service_discovery_container_name"></a> [service\_discovery\_container\_name](#input\_service\_discovery\_container\_name) | The container name used for service discovery. Should match the name in var.containers. Mandatory in case of multiple containers | `string` | `""` | no |
| <a name="input_cloud_map_namespace_id"></a> [cloud\_map\_namespace\_id](#input\_cloud\_map\_namespace\_id) | Cloud Map Namespace ID | `string` | `""` | no |
| <a name="input_service_discovery_service_name"></a> [service\_discovery\_service\_name](#input\_service\_discovery\_service\_name) | Name of the Service Discovery Service | `string` | `""` | no |
| <a name="input_ecs_exec_role_custom_policy_json"></a> [ecs\_exec\_role\_custom\_policy\_json](#input\_ecs\_exec\_role\_custom\_policy\_json) | Custom policy to attach to ecs task execution role. Document must be valid json. | `string` | `""` | no |
| <a name="input_ecs_role_custom_policy_json"></a> [ecs\_role\_custom\_policy\_json](#input\_ecs\_role\_custom\_policy\_json) | Custom policy to attach to ecs task role. Document must be valid json. | `string` | `""` | no |
| <a name="input_create_config_bucket"></a> [create\_config\_bucket](#input\_create\_config\_bucket) | Whether to create a config s3 bucket to store configurations | `bool` | `false` | no |
| <a name="input_config_objects"></a> [config\_objects](#input\_config\_objects) | A map of objects to be created in config\_bucket, where key is the object key in s3 bucket and value is the path of the file | `map(string)` | `{}` | no |
| <a name="input_kms_s3_key_arn"></a> [kms\_s3\_key\_arn](#input\_kms\_s3\_key\_arn) | ARN of the AWS S3 key used for the config S3 bucket encryption | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be associated with the provisioned infrastructures. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_json"></a> [container\_json](#output\_container\_json) | Container json for the ECS Task Definition |
| <a name="output_alb_dns"></a> [alb\_dns](#output\_alb\_dns) | DNS of the Application Load Balancer |
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_alb_dns_records"></a> [alb\_dns\_records](#output\_alb\_dns\_records) | Custom DNS record for the ALB |
| <a name="output_s3_logs_arn"></a> [s3\_logs\_arn](#output\_s3\_logs\_arn) | ARN of S3 bucket for logs |
| <a name="output_s3_logs_id"></a> [s3\_logs\_id](#output\_s3\_logs\_id) | ID of S3 bucket for logs |
| <a name="output_service_discovery_service_arn"></a> [service\_discovery\_service\_arn](#output\_service\_discovery\_service\_arn) | ARN of Service Discovery Service |
| <a name="output_service_discovery_service_id"></a> [service\_discovery\_service\_id](#output\_service\_discovery\_service\_id) | ID of Service Discovery Service |
| <a name="output_config_bucket_name"></a> [config\_bucket\_name](#output\_config\_bucket\_name) | ID of the config S3 bucket |
| <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn) | ECS Service ARN |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | ECS Service name |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ECS task definition ARN |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

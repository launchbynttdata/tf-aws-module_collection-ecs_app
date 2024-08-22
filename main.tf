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

# DNS Zone where the records for the ALB will be created
data "aws_route53_zone" "dns_zone" {
  count = length(var.dns_zone_name) > 0 || length(var.https_listeners) > 0 ? 1 : 0

  name         = var.dns_zone_name
  private_zone = var.private_zone
}

# This module generates the resource-name of resources based on resource_type, logical_product_family, logical_product_service, env etc.
module "resource_names" {
  source = "git::https://github.com/launchbynttdata/tf-launch-module_library-resource_name.git?ref=1.0.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = join("", split("-", var.region))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
}

module "config_bucket" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_collection-s3_bucket.git?ref=1.0.0"

  count = var.create_config_bucket ? 1 : 0

  bucket_name = module.resource_names["s3_config"].dns_compliant_minimal_random_suffix

  # Restrict all public access by default
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  kms_s3_key_arn = var.kms_s3_key_arn
  # If custom kms key is not provided, then it will default to AWS provided SSE (aws/s3)
  use_default_server_side_encryption = length(var.kms_s3_key_arn) > 0 ? false : true

  # required for object lock
  enable_versioning   = true
  object_lock_enabled = true

  tags = merge(local.tags, { resource_name = module.resource_names["s3_config"].standard })
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.14.1"

  count = length(var.alb_logs_bucket_id) > 0 ? 0 : 1

  bucket = module.resource_names["s3_logs"].dns_compliant_minimal_random_suffix

  # Allow deletion of non-empty bucket
  force_destroy = true
  # Required for ALB logs
  attach_elb_log_delivery_policy = var.load_balancer_type == "application" ? true : false
  # Required for NLB logs
  attach_lb_log_delivery_policy = var.load_balancer_type == "network" ? true : false

  # Restrict all public access by default
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = merge(local.tags, { resource_name = module.resource_names["s3_logs"].standard })
}

module "s3_bucket_objects" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version = "3.15.1"

  # This module is only applicable if the config_bucket is created and managed by wrapper module
  for_each = var.create_config_bucket && length(var.config_objects) > 0 ? var.config_objects : {}

  bucket      = module.config_bucket[0].id
  key         = each.key
  file_source = each.value

  # Will only work if object_lock and versioning are enabled in the bucket
  force_destroy = true

  tags = local.tags

}

# Security Group for ECS task
module "sg_ecs_service" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17.1"

  vpc_id      = var.vpc_id
  name        = module.resource_names["ecs_sg"].standard
  description = "Security Group for Virtual Gateway ECS Service"
  # Allows traffic only from the ALB (not used for NLB)
  computed_ingress_with_source_security_group_id = length(var.alb_sg) > 0 ? concat([
    {
      # Allow ingress from ALB on the health check port of target group (virtual gateway listener)
      from_port                = try(lookup(var.target_groups[0].health_check, "port"), 443)
      to_port                  = try(lookup(var.target_groups[0].health_check, "port"), 443)
      protocol                 = "tcp"
      source_security_group_id = module.sg_alb[0].security_group_id
    }
  ], local.ingress_with_sg) : []

  computed_egress_with_source_security_group_id = length(var.alb_sg) > 0 ? concat([
    {
      # Allow egress from ALB on the health check port of target group (virtual gateway listener)
      from_port                = try(lookup(var.target_groups[0].health_check, "port"), 443)
      to_port                  = try(lookup(var.target_groups[0].health_check, "port"), 443)
      protocol                 = "tcp"
      source_security_group_id = module.sg_alb[0].security_group_id
    }
  ], local.egress_with_sg) : []
  number_of_computed_ingress_with_source_security_group_id = var.load_balancer_type == "application" ? 1 + length(local.ingress_with_sg) : 0
  number_of_computed_egress_with_source_security_group_id  = var.load_balancer_type == "application" ? 1 + length(local.egress_with_sg) : 0

  # Other traffic rules
  ingress_cidr_blocks      = coalesce(try(lookup(var.ecs_svc_security_group, "ingress_cidr_blocks", []), []), [])
  ingress_rules            = coalesce(try(lookup(var.ecs_svc_security_group, "ingress_rules", []), []), [])
  ingress_with_cidr_blocks = coalesce(try(lookup(var.ecs_svc_security_group, "ingress_with_cidr_blocks", []), []), [])
  egress_cidr_blocks       = coalesce(try(lookup(var.ecs_svc_security_group, "egress_cidr_blocks", []), []), [])
  egress_rules             = coalesce(try(lookup(var.ecs_svc_security_group, "egress_rules", []), []), [])
  egress_with_cidr_blocks  = coalesce(try(lookup(var.ecs_svc_security_group, "egress_with_cidr_blocks", []), []), [])

  tags = merge(local.tags, { resource_name = module.resource_names["ecs_sg"].standard })

  # Config buckets may be needed by the ECS service to pull config before start up.
  depends_on = [module.config_bucket, module.s3_bucket_objects]
}

# Security Group for ALB
module "sg_alb" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17.1"

  count = length(var.alb_sg) > 0 ? 1 : 0

  vpc_id                   = var.vpc_id
  name                     = module.resource_names["alb_sg"].recommended_per_length_restriction
  description              = lookup(var.alb_sg, "description", "Security Group for ALB")
  ingress_cidr_blocks      = coalesce(try(lookup(var.alb_sg, "ingress_cidr_blocks", []), []), [])
  ingress_rules            = coalesce(try(lookup(var.alb_sg, "ingress_rules", []), []), [])
  ingress_with_cidr_blocks = coalesce(try(lookup(var.alb_sg, "ingress_with_cidr_blocks", []), []), [])
  egress_cidr_blocks       = coalesce(try(lookup(var.alb_sg, "egress_cidr_blocks", []), []), [])
  egress_rules             = coalesce(try(lookup(var.alb_sg, "egress_rules", []), []), [])
  egress_with_cidr_blocks  = coalesce(try(lookup(var.alb_sg, "egress_with_cidr_blocks", []), []), [])

  tags = merge(local.tags, { resource_name = module.resource_names["alb_sg"].standard })
}

# Certificate Manager where the certs for ALB will be provisioned
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.3.2"

  # Same ACM cert can be used for all http listeners
  count = length(var.https_listeners) > 0 ? 1 : 0

  # First domain name must be < 64 chars
  domain_name               = "${module.resource_names["alb"].recommended_per_length_restriction}.${var.dns_zone_name}"
  subject_alternative_names = concat(local.san, var.subject_alternate_names)
  zone_id                   = data.aws_route53_zone.dns_zone[count.index].zone_id

  tags = merge(local.tags, { resource_name = module.resource_names["acm"].standard })
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.7"

  name_prefix        = "lb-"
  internal           = var.is_internal
  load_balancer_type = var.load_balancer_type
  # SG is created by separate module
  create_security_group = false

  vpc_id = var.vpc_id
  # Only one out of subnets or subnet_mapping can be specified
  subnets        = var.is_internal ? (length(var.subnet_mapping) > 0 ? null : var.private_subnets) : (length(var.subnet_mapping) > 0 ? null : var.public_subnets)
  subnet_mapping = var.subnet_mapping
  # Security group can be used for both NLB and ALB
  security_groups = length(var.alb_sg) > 0 ? [module.sg_alb[0].security_group_id] : []

  access_logs = {
    bucket = length(var.alb_logs_bucket_id) > 0 ? var.alb_logs_bucket_id : module.s3_bucket[0].s3_bucket_id
    # This is required for this issue https://github.com/hashicorp/terraform-provider-aws/issues/16674
    enabled = true
    prefix  = var.alb_logs_bucket_prefix
  }

  target_groups = local.target_groups

  http_tcp_listeners               = local.http_tcp_listeners
  https_listeners                  = local.https_listeners
  enable_http2                     = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  http_tcp_listeners_tags = merge(local.tags, { Id = module.resource_names["alb_http_listener"].standard })

  tags = merge(local.tags, { resource_name = module.resource_names["alb"].standard })

  depends_on = [module.s3_bucket]
}

module "container_definitions" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=0.58.2"

  for_each = length(local.containers_map) > 0 ? local.containers_map : {}

  command                      = each.value.command
  container_name               = each.value.name
  container_memory             = each.value.memory
  container_memory_reservation = each.value.memory_reservation
  container_cpu                = each.value.cpu
  essential                    = each.value.essential
  readonly_root_filesystem     = each.value.readonly_root_filesystem
  map_environment              = each.value.environment
  map_secrets                  = each.value.secrets
  mount_points                 = each.value.mount_points
  port_mappings                = each.value.port_mappings
  healthcheck                  = each.value.healthcheck
  user                         = each.value.user
  container_depends_on         = each.value.container_depends_on
  log_configuration = each.value.log_configuration == null ? {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/fargate/task/${module.resource_names["ecs_service"].standard}"
      awslogs-region        = var.region
      awslogs-create-group  = "true"
      awslogs-stream-prefix = each.value.name
    }
  } : each.value.log_configuration
}

module "service_discovery_service" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-service_discovery_service.git?ref=1.0.0"

  count = var.enable_service_discovery ? 1 : 0

  name         = length(var.service_discovery_service_name) > 0 ? var.service_discovery_service_name : var.resource_names_map["ecs_service"].name
  namespace_id = var.cloud_map_namespace_id

  tags = merge(
    local.tags,
    {
      Name          = length(var.service_discovery_service_name) > 0 ? var.service_discovery_service_name : var.resource_names_map["ecs_service"].name
      resource_name = module.resource_names["ecs_service"].standard
    }
  )
}

# The permissions needed by ECS task to start
module "ecs_task_execution_policy" {
  count = length(var.ecs_exec_role_custom_policy_json) > 0 ? 1 : 0

  source  = "cloudposse/iam-policy/aws"
  version = "~> 0.4.0"

  enabled                       = true
  namespace                     = "${var.logical_product_family}-${var.logical_product_service}-${join("", split("-", var.region))}"
  stage                         = var.environment_number
  environment                   = var.environment
  name                          = "${var.resource_names_map["task_exec_policy"].name}-${var.resource_number}"
  iam_policy_enabled            = true
  iam_override_policy_documents = [var.ecs_exec_role_custom_policy_json]
}

# The permissions needed by the application in the task to run
module "ecs_task_policy" {
  count = length(var.ecs_role_custom_policy_json) > 0 ? 1 : 0

  source  = "cloudposse/iam-policy/aws"
  version = "~> 0.4.0"

  enabled                     = true
  namespace                   = "${var.logical_product_family}-${var.logical_product_service}-${join("", split("-", var.region))}"
  stage                       = var.environment_number
  environment                 = var.environment
  name                        = "${var.resource_names_map["task_policy"].name}-${var.resource_number}"
  iam_policy_enabled          = true
  iam_source_policy_documents = [var.ecs_role_custom_policy_json]
}

# ECS Service
module "ecs_alb_service_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "~> 0.67.1"
  # This module generates its own name. Can't use the labels module
  namespace                          = "${var.logical_product_family}-${var.logical_product_service}"
  stage                              = var.environment_number
  name                               = var.resource_names_map["ecs_service"].name
  environment                        = var.environment
  attributes                         = [var.resource_number]
  delimiter                          = "-"
  alb_security_group                 = length(var.alb_sg) > 0 ? module.sg_alb[0].security_group_id : ""
  container_definition_json          = jsonencode([for container in module.container_definitions : container.json_map_object])
  bind_mount_volumes                 = var.bind_mount_volumes
  ecs_cluster_arn                    = var.ecs_cluster_arn
  launch_type                        = var.ecs_launch_type
  vpc_id                             = var.vpc_id
  security_group_ids                 = [module.sg_ecs_service.security_group_id]
  security_group_enabled             = false
  subnet_ids                         = var.private_subnets
  ignore_changes_task_definition     = var.ignore_changes_task_definition
  ignore_changes_desired_count       = var.ignore_changes_desired_count
  task_exec_policy_arns_map          = local.task_exec_policy_arns_map
  task_policy_arns_map               = local.task_policy_arns_map
  network_mode                       = var.network_mode
  assign_public_ip                   = var.assign_public_ip
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_controller_type         = var.deployment_controller_type
  desired_count                      = var.desired_count
  task_memory                        = var.task_memory
  task_cpu                           = var.task_cpu
  wait_for_steady_state              = var.wait_for_steady_state
  # Issue: https://github.com/hashicorp/terraform-provider-aws/issues/16674
  force_new_deployment = var.force_new_deployment
  redeploy_on_apply    = var.redeploy_on_apply
  service_registries   = local.service_registries
  runtime_platform     = var.runtime_platform

  ecs_load_balancers = [
    {
      container_name   = try(var.containers[0].name, "name_missing")
      container_port   = try(var.containers[0].port_mappings[0].containerPort, 80)
      target_group_arn = module.alb.target_group_arns[0]
      # If target_group is specified, elb_name must be null
      elb_name = null
    }
  ]

  tags = merge(local.tags, { resource_name = module.resource_names["ecs_service"].standard })
}

module "alb_dns_record" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-dns_record.git?ref=1.0.0"

  count = length(var.dns_zone_name) > 0 ? 1 : 0

  zone_id = var.dns_zone_name
  records = local.alb_dns_records
}

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

locals {

  default_tags = {
    provisioner = "Terraform"
  }

  # Inject tags to target group
  target_groups = [for tg in var.target_groups : merge(tg, { tags = {
    resource_name = module.resource_names["alb_tg"].standard
  } })]

  service_registries = var.enable_service_discovery && length(var.service_discovery_container_name) > 0 ? [
    for container in var.containers :
    merge(container, { registry_arn = module.service_discovery_service[0].arn })
    if container.name == var.service_discovery_container_name
  ] : []

  ingress_with_sg_block = coalesce(try(lookup(var.ecs_svc_security_group, "ingress_with_sg", []), []), [])
  ingress_with_sg = length(local.ingress_with_sg_block) > 0 && var.load_balancer_type == "application" ? [
    for sg in local.ingress_with_sg_block : {
      from_port                = try(lookup(sg, "port"), 443)
      to_port                  = try(lookup(sg, "port"), 443)
      protocol                 = try(lookup(sg, "protocol"), "tcp")
      source_security_group_id = sg.security_group_id
    }

  ] : []

  egress_with_sg_block = coalesce(try(lookup(var.ecs_svc_security_group, "egress_with_sg", []), []), [])
  egress_with_sg = length(local.egress_with_sg_block) > 0 && var.load_balancer_type == "application" ? [
    for sg in local.egress_with_sg_block : {
      from_port                = try(lookup(sg, "port"), 443)
      to_port                  = try(lookup(sg, "port"), 443)
      protocol                 = try(lookup(sg, "protocol"), "tcp")
      source_security_group_id = sg.security_group_id
    }

  ] : []

  # ACM cert doesnt allow first domain name > 64 chars. Hence, add a SAN for the standard name of ALB in-case the actual ALB name > 32 characters and a shortened name is used for ALB
  # We still would like to use the standard name in the custom A-record
  san = module.resource_names["alb"].recommended_per_length_restriction != module.resource_names["alb"].standard ? ["${module.resource_names["alb"].standard}.${var.dns_zone_name}"] : []

  # append the certificate_arn and target_group_index to https_listener object. This assumes that number of listeners = num of target_groups
  https_listeners = [
    for index, arn in var.https_listeners : merge(var.https_listeners[index], {
      certificate_arn = module.acm[0].acm_certificate_arn, target_group_index = index,
      ssl_policy      = var.listener_ssl_policy_default
    })
  ]

  http_to_https_redirect_listener = {
    port        = 80
    protocol    = "HTTP"
    action_type = "redirect"
    redirect = {
      port        = try(var.https_listeners[0].port, "443")
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  http_tcp_listeners = length(var.http_tcp_listeners) > 0 ? var.http_tcp_listeners : var.load_balancer_type == "application" && var.redirect_to_https ? [local.http_to_https_redirect_listener] : []

  # Need to construct the alb_dns_records as a map of object (alias A record)
  alb_dns_records = {
    (module.resource_names["alb"].standard) = {
      type = "A"
      alias = {
        name    = module.alb.lb_dns_name
        zone_id = module.alb.lb_zone_id
      }
    }
  }

  task_exec_role_default_managed_policies_map = {
    ecs_task_exec = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  task_role_default_managed_policies_map = {}

  task_exec_policy_arns_map = length(var.ecs_exec_role_custom_policy_json) > 0 ? merge(local.task_exec_role_default_managed_policies_map, { custom_policy = module.ecs_task_execution_policy[0].policy_arn }) : local.task_exec_role_default_managed_policies_map
  task_policy_arns_map      = length(var.ecs_role_custom_policy_json) > 0 ? merge(local.task_role_default_managed_policies_map, { custom_policy = module.ecs_task_policy[0].policy_arn }) : local.task_role_default_managed_policies_map

  # Otel specific
  otel_config_file_contents = length(var.otel_config_file_name) > 0 ? filebase64("${path.module}/${var.otel_config_file_name}") : ""

  additional_environment_map = {
    nginx          = {}
    decoder        = {}
    nginx_exporter = {}
    otel_init = {
      OTEL_CONFIG_FILE_CONTENTS = local.otel_config_file_contents
      ECS_SERVICE_NAME          = module.resource_names["ecs_service"].standard
    }
    otel_collector = {
      ECS_SERVICE_NAME = module.resource_names["ecs_service"].standard
    }
  }

  containers_map = {
    for container in var.containers : container.name => {
      name                     = container.name
      image_tag                = container.image_tag
      command                  = container.command
      essential                = container.essential
      cpu                      = container.cpu
      memory                   = container.memory
      memory_reservation       = container.memory_reservation
      readonly_root_filesystem = container.readonly_root_filesystem
      environment              = merge(container.environment, var.app_environment, try(local.additional_environment_map[container.name], {}))
      secrets                  = merge(container.secrets, var.app_secrets)
      mount_points             = container.mount_points
      port_mappings            = container.port_mappings
      healthcheck              = container.healthcheck
      user                     = container.user
      container_depends_on     = container.container_depends_on
      log_configuration        = container.log_configuration
    }
  }

  tags = merge(local.default_tags, var.tags)
}

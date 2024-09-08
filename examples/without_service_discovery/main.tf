
data "aws_caller_identity" "default" {}

module "ecs_platform" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_collection-ecs_platform.git?ref=1.1.0"

  gateway_vpc_endpoints      = var.gateway_vpc_endpoints
  interface_vpc_endpoints    = var.interface_vpc_endpoints
  logical_product_family     = var.logical_product_family
  logical_product_service    = var.logical_product_service
  vpce_security_group        = var.vpce_security_group
  resource_names_map         = var.resource_names_map
  region                     = var.region
  environment                = var.environment
  environment_number         = var.environment_number
  resource_number            = var.resource_number
  container_insights_enabled = var.container_insights_enabled
  namespace_name             = var.namespace_name
  create_vpc                 = var.create_vpc
  vpc                        = var.vpc
  tags                       = var.tags
}

# Number of ECRs should be same as number of containers in the task definition
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2.1"

  repository_name          = var.ecr_repo_name
  attach_repository_policy = false
  create_lifecycle_policy  = false
  repository_force_delete  = var.repo_force_delete

  tags = var.tags
}

resource "terraform_data" "ecr_push" {
  provisioner "local-exec" {
    command = <<-EOT
      # Make sure user is logged in to AWS to the same profile specified here
      aws ecr get-login-password --region ${var.region} --profile ${var.aws_profile} | docker login --username AWS --password-stdin ${data.aws_caller_identity.default.account_id}.dkr.ecr.${var.region}.amazonaws.com
      docker pull --platform=linux/amd64  nginx:1.22.1-alpine
      docker tag  nginx:1.22.1-alpine "${module.ecr.repository_url}:${var.image_tag}"
      docker push "${module.ecr.repository_url}:${var.image_tag}"

    EOT
  }

  depends_on = [module.ecr]
}

module "ecs_app" {
  source = "../.."

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.region
  environment             = var.environment
  environment_number      = var.environment_number
  resource_number         = var.resource_number
  resource_names_map      = var.resource_names_map

  vpc_id                 = module.ecs_platform.vpc_id
  private_subnets        = module.ecs_platform.private_subnet_ids
  ecs_svc_security_group = var.ecs_svc_sg
  alb_sg                 = var.alb_sg
  is_internal            = var.is_internal
  load_balancer_type     = var.load_balancer_type
  target_groups          = var.target_groups

  # Needs to inject the container image
  containers                         = local.containers
  ecs_cluster_arn                    = module.ecs_platform.fargate_arn
  ecs_launch_type                    = var.ecs_launch_type
  ignore_changes_desired_count       = var.ignore_changes_desired_count
  ignore_changes_task_definition     = var.ignore_changes_task_definition
  network_mode                       = var.network_mode
  assign_public_ip                   = var.assign_public_ip
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_controller_type         = var.deployment_controller_type
  desired_count                      = var.desired_count
  task_memory                        = var.task_memory
  task_cpu                           = var.task_cpu
  wait_for_steady_state              = var.wait_for_steady_state
  http_tcp_listeners                 = var.http_listeners
  https_listeners                    = var.https_listeners

  enable_service_discovery         = var.enable_service_discovery
  service_discovery_container_name = var.service_discovery_container_name
  service_discovery_service_name   = var.service_discovery_service_name
  cloud_map_namespace_id           = module.ecs_platform.namespace_id

  app_image = var.app_image

  tags = var.tags
}

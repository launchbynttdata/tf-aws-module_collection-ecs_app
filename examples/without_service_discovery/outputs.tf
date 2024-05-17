output "interface_vpc_endpoints" {
  value = module.ecs_platform.interface_endpoints
}

output "gateway_vpc_endpoints" {
  value = module.ecs_platform.gateway_endpoints
}

output "vpce_sg_id" {
  value = module.ecs_platform.vpce_sg_id
}

output "ecs_cluster_arn" {
  value = module.ecs_platform.fargate_arn
}

output "ecr_url" {
  value = module.ecr.repository_url
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns" {
  value = module.ecs_app.alb_dns
}

output "service_discovery_service_id" {
  value = module.ecs_app.service_discovery_service_id
}

output "namespace_id" {
  value = module.ecs_platform.namespace_id
}

output "namespace_hosted_zone" {
  value = module.ecs_platform.namespace_hosted_zone
}

output "ecs_cluster_name" {
  value = module.ecs_platform.resource_names["ecs_cluster"]
}

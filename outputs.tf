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

output "container_json" {
  description = "Container json for the ECS Task Definition"
  value       = var.print_container_json ? [for name, container in module.container_definitions : container.json_map_object] : null
}

output "alb_dns" {
  description = "DNS of the Application Load Balancer"
  value       = module.alb.lb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.lb_arn
}

output "alb_dns_records" {
  description = "Custom DNS records for the ALB"
  value       = try([for key, value in module.alb_dns_record[0].record_fqdns : value], [])
}

output "alb_additional_dns_names" {
  description = "Additional DNS records for the ALB"
  value       = flatten([for dns_record in module.additional_cnames : [for key, value in dns_record.record_fqdns : key]])
}

output "alb_target_group_arns" {
  description = "ARNs of the ALB Target Groups"
  value       = module.alb.target_group_arns
}

output "alb_target_group_names" {
  description = "Names of the ALB Target Groups"
  value       = module.alb.target_group_names
}

output "s3_logs_arn" {
  description = "ARN of S3 bucket for logs"
  value       = try(module.s3_bucket[0].s3_bucket_arn, "")
}

output "s3_logs_id" {
  description = "ID of S3 bucket for logs"
  value       = try(module.s3_bucket[0].s3_bucket_id, var.alb_logs_bucket_id)
}

output "service_discovery_service_arn" {
  description = "ARN of Service Discovery Service"
  value       = try(module.service_discovery_service[0].arn, "")
}

output "service_discovery_service_id" {
  description = "ID of Service Discovery Service"
  value       = try(module.service_discovery_service[0].id, "")
}

output "config_bucket_name" {
  description = "ID of the config S3 bucket"
  value       = var.create_config_bucket ? module.resource_names["s3_config"].recommended_per_length_restriction : ""
}

output "ecs_service_arn" {
  description = "ECS Service ARN"
  value       = module.ecs_alb_service_task.service_arn
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = module.ecs_alb_service_task.service_name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = module.ecs_alb_service_task.task_definition_arn
}

output "ecr_repository_url" {
  description = "ECR Repository URL. Only valid when var.create_ecr_repo=true"
  value       = try(module.ecr[0].repository_url, "")
}

# This tfvars file is used to create a new ECS service with Fargate launch type with the ECS app in a private subnet
# fronted by a public ALB in the public subnet. The ALB is configured with TLS termination and the certificate is provisioned
# in ACM. The DNS record pointing to the ALB is created in the Public DNS Zone passed in as inputs.

# The inputs to this file are:
# - ECS Cluster ARN
# - ECR Repository Name
# - VPC with private/public subnets

# Fill in all the values below marked with <>

logical_product_family  = "www"
logical_product_service = "fe"
environment             = "sandbox"
region                  = "us-east-2"
vpc_id                  = "<vpc-id>"
private_subnets         = ["<list-of-private-subnet-ids>"]


public_subnets = ["<list-of-public-subnet-ids>"]

ecs_cluster_arn = "<ecs-cluster-arn>"

ecr_repo_name   = "<repo_name>"
create_ecr_repo = true
force_delete    = true

app_image = "<aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com/<repo_name>>:<docker_image_tag>"

alb_sg = {
  description         = "Allow traffic from everywhere on 80"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

ecs_svc_security_group = {
  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}
containers = [
  {
    name      = "backend"
    essential = true
    log_configuration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/fargate/task/demo-app-server"
        awslogs-region        = "us-east-2"
        awslogs-create-group  = "true"
        awslogs-stream-prefix = "demoapp"
      }
    }
    environment = {
      PORT = "80"
    }
    port_mappings = [{
      # port mappings should also change in target group and ecs security group
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }
]

target_groups = [
  {
    backend_protocol = "HTTP"
    backend_port     = 80
    target_type      = "ip"
  }
]

https_listeners = [
  {
    port     = 443
    protocol = "HTTPS"
  }
]

enable_service_discovery = false

ignore_changes_task_definition = false
ignore_changes_desired_count   = false
force_new_deployment           = true
wait_for_steady_state          = true
redeploy_on_apply              = true

print_container_json = false

desired_count = 2

is_internal        = false
load_balancer_type = "application"
dns_zone_name      = "<dns_zone_name>"
private_zone       = false
additional_cnames  = ["<fddn-cnames"]

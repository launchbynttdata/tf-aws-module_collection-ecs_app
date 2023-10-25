# User needs to manually populate the fields specified within <> before applying the terraform
naming_prefix = "app2"

vpc_id          = "<vpc_id>"
private_subnets = ["<list of subnets - comma separated strings>"]


alb_sg = {
  description         = "Allow traffic from everywhere on 80"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

ecs_svc_sg = {
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
  ingress_port       = "80"
}
containers = [
  {
    name      = "backend"
    image_tag = "<ecr_registry_id>/<repository>:<image_tag>"
    log_configuration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/fargate/task/demo-app-server"
        awslogs-region        = "us-east-2"
        awslogs-create-group  = "true"
        awslogs-stream-prefix = "flask"
      }
    }
    environment = {
      # key value pairs
    }
    port_mappings = [{
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
http_listener  = {}
https_listener = {}

force_new_deployment = false
redeploy_on_apply    = false

ecs_cluster_arn = "<ecs_cluster_arn>"

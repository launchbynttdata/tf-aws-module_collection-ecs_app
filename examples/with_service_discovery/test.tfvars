logical_product_service = "dso102"
# Ensure you have a profile by this name in your ~/.aws/config file
aws_profile = "launch-sandbox-admin"

resource_names_map = {
  # Platform
  ecs_cluster = {
    name = "fargate"
  }
  vpce_sg = {
    name = "vpce-sg"
  }
  vpce_sg = {
    name = "vpc"
  }
  namespace = {
    name = "ns"
  }
  # Application
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
    max_length = 31
  }
}

vpc_cidr           = "10.2.0.0/16"
private_subnets    = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

interface_vpc_endpoints = {
  ecrdkr = {
    service_name        = "ecr.dkr"
    private_dns_enabled = true
  }
  ecrapi = {
    service_name        = "ecr.api"
    private_dns_enabled = true
  }
  ecs = {
    service_name        = "ecs"
    private_dns_enabled = true
  }
  logs = {
    service_name        = "logs"
    private_dns_enabled = true
  }
}

gateway_vpc_endpoints = {
  s3 = {
    service_name        = "s3"
    private_dns_enabled = true
  }
}

vpce_security_group = {
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

ecr_repo_name     = "terratest-backend-3456"
repo_force_delete = true


alb_sg = {
  description         = "Allow traffic from everywhere on 80"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

ecs_svc_sg = {
  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

containers = [
  {
    name = "backend"
    # image_tag will be injected in locals.tf
    # image_tag = ""
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
      FLASK_RUN_PORT = "8081"
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
http_listeners = [
  {
    port        = 80
    protocol    = "HTTP"
    action_type = "forward"
    redirect    = {}
  }
]
https_listeners = []

enable_service_discovery         = true
namespace_name                   = "example1010.local"
service_discovery_container_name = "backend"
service_discovery_service_name   = "test1"

tags = {
  Purpose = "terratest examples"
  Env     = "sandbox"
  Team    = "dso"
}

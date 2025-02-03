environment = "prod"
aws_region  = "eu-central-1"

vpc_cidr = "10.2.0.0/16"
public_subnet_cidr = [
  {
    cidr = "10.2.0.0/19"
    az   = "eu-central-1a"
  },
  {
    cidr = "10.2.32.0/19"
    az   = "eu-central-1b"
  },
  {
    cidr = "10.2.64.0/19"
    az   = "eu-central-1c"
  }
]

private_subnet_cidr = [
  {
    cidr = "10.2.96.0/19"
    az   = "eu-central-1a"
  },
  {
    cidr = "10.2.128.0/19"
    az   = "eu-central-1b"
  },
  {
    cidr = "10.2.160.0/19"
    az   = "eu-central-1c"
  }
]

rds_db_username = "admin"

eks_cluster_permissions = []

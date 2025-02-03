environment = "pre-prod"
aws_region  = "eu-central-1"

vpc_cidr = "10.1.0.0/16"
public_subnet_cidr = [
  {
    cidr = "10.1.0.0/19"
    az   = "eu-central-1a"
  },
  {
    cidr = "10.1.32.0/19"
    az   = "eu-central-1b"
  },
  {
    cidr = "10.1.64.0/19"
    az   = "eu-central-1c"
  }
]

private_subnet_cidr = [
  {
    cidr = "10.1.96.0/19"
    az   = "eu-central-1a"
  },
  {
    cidr = "10.1.128.0/19"
    az   = "eu-central-1b"
  },
  {
    cidr = "10.1.160.0/19"
    az   = "eu-central-1c"
  }
]

rds_db_username = "admin"

eks_cluster_permissions = [
  {
    principal_arn         = "arn:aws:iam::266735825304:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_Administrator_309d444573106950",
    permission_ploicy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  },
  {
    principal_arn         = "arn:aws:iam::266735825304:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_ReadAndWrite_6f31a510dca4bcae",
    permission_ploicy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  },
  {
    principal_arn         = "arn:aws:iam::266735825304:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_ReadOnly_d0c685847d9509ce",
    permission_ploicy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
  }
]

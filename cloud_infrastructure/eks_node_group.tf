resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_ro_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_ssm_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_launch_template" "eks_ng_lt" {
  name          = "eks-ng-lt-${var.environment}"
  image_id      = var.node_group_ami
  instance_type = var.node_group_instance_type
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 80
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    /etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster.name} \
      --container-runtime containerd \
      --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${var.node_group_ami}'
    EOF
  )
  network_interfaces {
    delete_on_termination = true
    security_groups       = [for vc in aws_eks_cluster.eks_cluster.vpc_config : vc.cluster_security_group_id]
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                     = "eks-node-${var.environment}"
      "created-and-managed-by" = "terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name                     = "eks-node-${var.environment}"
      "created-and-managed-by" = "terraform"
    }
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group-${var.environment}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = local.private_subnet_ids

  launch_template {
    id      = aws_launch_template.eks_ng_lt.id
    version = aws_launch_template.eks_ng_lt.latest_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_container_registry_ro_policy_attachment,
    aws_iam_role_policy_attachment.eks_ssm_policy_attachment
  ]
  tags = {
    "alpha.eksctl.io/cluster-name"                = aws_eks_cluster.eks_cluster.name
    "alpha.eksctl.io/nodegroup-name"              = "eks-node-group-${var.environment}"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = aws_eks_cluster.eks_cluster.name
    "alpha.eksctl.io/nodegroup-type"              = "managed"
  }

  labels = {
    "alpha.eksctl.io/cluster-name"   = aws_eks_cluster.eks_cluster.name
    "alpha.eksctl.io/nodegroup-name" = "eks-node-group-${var.environment}"
  }
}

data "aws_iam_policy_document" "aws_access" {
  statement {
    sid    = "EKSClusterTOS3Access"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.ecom_s3.arn,
      "${aws_s3_bucket.ecom_s3.arn}/*"
    ]
  }
  statement {
    sid    = "EKSCreateVolumeAccess"
    effect = "Allow"
    actions = [
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumeModifications",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "EKSClusterToSecretManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.isms24-secrets.arn,
    ]
  }
}

resource "aws_iam_role_policy" "eks_node_aws_access_policy_attach" {
  name   = "eks-access-to-aws-resources-policy-${var.environment}"
  role   = aws_iam_role.eks_node_role.id
  policy = data.aws_iam_policy_document.aws_access.json
}

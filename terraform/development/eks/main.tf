module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = data.aws_vpc.aily_vpc.id  # "vpc-08f56565b4cca1961"
  subnet_ids               = [data.aws_subnet.aily_vpc_public_us_east_1a.id, data.aws_subnet.aily_vpc_public_us_east_1b.id]  #["subnet-abcde012", "subnet-bcde012a"]
  control_plane_subnet_ids = [data.aws_subnet.aily_vpc_public_us_east_1a.id, data.aws_subnet.aily_vpc_public_us_east_1b.id] #["subnet-xyzde987", "subnet-slkjf456"]

  eks_managed_node_groups = {
    green = {
      subnet_ids   = [data.aws_subnet.aily_vpc_private_us_east_1a.id, data.aws_subnet.aily_vpc_private_us_east_1b.id]
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }


  # aws-auth configmap
  manage_aws_auth_configmap = false

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::953835556803:user/joan.porta"
      username = "user1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "953835556803",
  ]
}
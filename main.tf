
locals {
  name            = basename(path.cwd)
  region          = var.aws_region
  cluster_version = "1.24"
  vpc_cidr      = "10.0.0.0/16"
  azs           = slice(data.aws_availability_zones.available.names, 0, 3)
  node_group_name = "managed-ondemand"
  env = "dev"
  fargate_profile_name     = {
    fargate_profile_name = "fp-default"
    name = "fp-default"
  }
}
################################################################################
# Cluster
################################################################################
 
#tfsec:ignore:aws-eks-enable-control-plane-logging

module "eks_blueprints" {
  source  = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.26.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  
  vpc_id     = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profiles = {
    default = {
      fargate_profile_name = "fp-default"
      fargate_profile_namespaces = [
        {
          namespace = "default"
          k8s_labels = {}
        },
        {
          namespace = "kube-system"
          k8s_labels = {}
        }
      ]
    }
    app_wildcard = {
      selectors = [
        { namespace = "app-*" }
      ]
    }
    kube_system = {
      name = "kube-system"
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }
}

 

################################################################################

# Kubernetes Addons

################################################################################
module "kubernetes_addons" {
   source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.26.0/modules/kubernetes-addons"

   eks_cluster_id     = module.eks_blueprints.eks_cluster_id

   #---------------------------------------------------------------
   # CORE DNS ADD-ON
   #---------------------------------------------------------------

   enable_amazon_eks_coredns = true
   amazon_eks_coredns_config = {
     most_recent        = true
     kubernetes_version = "1.23"
     resolve_conflicts  = "OVERWRITE"
   }

   #---------------------------------------------------------------
   # ADD-ONS - You can add additional addons here
   # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
   #---------------------------------------------------------------

   enable_aws_load_balancer_controller  = true
   enable_amazon_eks_aws_ebs_csi_driver = true
   enable_aws_for_fluentbit             = true
   enable_metrics_server                = true

 }
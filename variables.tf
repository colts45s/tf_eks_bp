variable "aws_region" {
    description = "Name of the AWS region to place resources"
    type = string
    default = "us-east-2"
}
variable "fargate_profiles" {
    description = "Map of maps 'eks_node_groups' to create"
    type = any
    default = {
        "fargate_profile_name" = "fp-default"
        "name" = "fp-default"
    }
}
variable "vpc_id" {
    description = "VPC id of vpc the to place resources"
    type = string
    default = "vpc-00beea2ab6f09db53"
}
variable "private_subnet_ids" {
    description = "Array of private subnet ids for cluster"
    type = list(string)
    default = ["subnet-073f6b1149bc6ef5a","subnet-05eb9ad43a44d6d68","subnet-039fbffea5442b5d6"]
}
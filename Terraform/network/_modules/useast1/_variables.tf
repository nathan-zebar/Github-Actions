variable "network_deployments" {
    description = "Variable for deploying network resources"
    type = map(object({
        name = string
        cidr_block = string
        secondary_cidr_blocks = list(string)
        subnets = list(object({
            associated_vpc_cidr = string
            subnet_cidr_blocks = list(string)
        }))
        create_internet_gateway = bool
        nat_gateways = list(string)
        route_tables = list(object({
            name = string
            routes = list(string)
            subnet_cidr_associations = list(string)
        }))
        network_tags = map(string)
    }))
  default = {}
}

variable "useast1_azs" {
  description = "Declare AZs for subnet placement"
  type = map(string)
  default = {
      A = "us-east-1a"
      B = "us-east-1b"
      C = "us-east-1c"
      D = "us-east-1d"
      E = "us-east-1e"
      F = "us-east-1f"
  }
}

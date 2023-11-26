module "useast1_network" {
source = "../_modules/useast1"

network_deployments = {
    #-----------------------------------------------#
    vpc_001 = {
        #- VPC
        name = "vpc_001"
        cidr_block = "192.168.0.0/16"
        secondary_cidr_blocks = []
        #- Subnets
        subnets = [
            {
                associated_vpc_cidr = "192.168.0.0/16"
                subnet_cidr_blocks = [
                #Syntax: tag:Name | CIDR | Availability Zone
                    "public_subnet|192.168.4.0/24|A",
                    "private_subnet|192.168.16.0/24|A",
                ]
            }
        ]
        #- External Communication
        create_internet_gateway = true
        nat_gateways = [
            "natgw_001|192.168.4.0/24"
        ]
        #- Route Tables
        route_tables = [
            # Route Syntax: Destination Type | Destination CIDR | Endpoint ID
            # igw = Internet Gateway
            # natgw = NAT Gateway 
            {
                name = "private_rt"
                routes = [
                    "natgw|0.0.0.0/0|natgw_001"
                ]
                subnet_cidr_associations = ["192.168.16.0/24"]
            },
            {
                name = "public_rt"
                routes = [
                    "igw|0.0.0.0/0"
                ]
                subnet_cidr_associations = [
                    "192.168.4.0/24"
                ]
            }
        ]
        #- Tags
        network_tags = {
            network = "vpc_001",
            deployment = "terraform"
            project = "aws-ecs-docker-terraform"
        }
    }
    #-----------------------------------------------#
} 
###################
## END OF MODULE ##
###################
}
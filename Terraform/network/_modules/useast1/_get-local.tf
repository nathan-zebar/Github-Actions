locals {

    #-- Get VPC Names

    vpc = flatten( [ for key, value in var.network_deployments: {
                        index_key = value.name
                        cidr_block = value.cidr_block
                        network_tags = value.network_tags
        } ] )

    #-------------------------------------------------------------#
  
    #-- Get Secondary CIDR Blocks
    secondary_cidr_blocks = flatten( [for key, value in var.network_deployments:
                                    [for key2 in value.secondary_cidr_blocks: {
                                        index_key = value.name
                                        secondary_cidr_blocks = key2
                                    }]
                                ])

    #-------------------------------------------------------------#

    #-- Get Subnets to associate with VPC CIDRs
    vpc_subnets = flatten([ for key, value in var.network_deployments: [ 
                                for key2 in value.subnets: [
                                    for key3 in key2.subnet_cidr_blocks: {
                                        index_key = value.name
                                        secondary_cidr_blocks = value.secondary_cidr_blocks
                                        associated_vpc_cidr = key2.associated_vpc_cidr
                                        subnet_cidr_block = key3
                                        network_tags = value.network_tags
                                }
                            ] ]
     ])

     #-------------------------------------------------------------#

     #-- Get Route Tables and Associate Subnets

    route_tables = flatten( [ for key, value in var. network_deployments: [
                                for key2 in value.route_tables: {
                                    index_key = value.name
                                    name = key2.name
                                    network_tags = value.network_tags
                                }
                            ] ] )

    #-- Get Route Table Routes
    rt_routes = flatten( [ for key, value in var.network_deployments: [
                            for key2 in value.route_tables: [
                             for key3 in key2.routes: {
                                index_key = value.name
                                rt_name = key2.name
                                route = key3
                             }
                        ] ] ] )

    #-- Get Route Table Associations
    rt_associations = flatten( [ for key, value in var.network_deployments: [
                                    for key2 in value.route_tables: [
                                        for key3 in key2.subnet_cidr_associations: {
                                            index_key = value.name
                                            rt_name = key2.name
                                            cidr = key3
                                        }
                                    ]
    ] ] )

    #-- Get Internet Gateways
    internet_gateways = flatten([ for key, value in var.network_deployments: {
                                    index_key = value.name
                                    tag_name = "${value.name}-igw"
                                    network_tags = value.network_tags
                                } if value.create_internet_gateway == true
                                ] )

    #--- Get Nat Gateways
    nat_gateways = flatten( [ for key, value in var.network_deployments: [
                                for key2 in value.nat_gateways: {
                                    index_key = value.name
                                    nat_gateway = key2
                                    network_tags = value.network_tags
                                }
                            ] ] )

}
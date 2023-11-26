
#-------------------------------------------------------------#

resource "aws_vpc" "useast1_vpc_01" {
for_each = {for o in local.vpc: o.index_key => o}

  cidr_block = each.value.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    {Name = each.value.index_key},
    each.value.network_tags
  )
}

#-------------------------------------------------------------#

resource "aws_vpc_ipv4_cidr_block_association" "useast1_secondary_vpc_cidr" {
for_each = { for o in local.secondary_cidr_blocks: "${o.index_key}-${o.secondary_cidr_blocks}" => o}
  
  vpc_id     = aws_vpc.useast1_vpc_01[each.value.index_key].id
  cidr_block = each.value.secondary_cidr_blocks
}

#-------------------------------------------------------------#

resource "aws_subnet" "useast1_subnets" {
for_each = { for o in local.vpc_subnets: "${o.index_key}-${element(split("|", o.subnet_cidr_block), 1)}" => o} 
  
  vpc_id     = contains( each.value.secondary_cidr_blocks, each.value.associated_vpc_cidr) == true ? aws_vpc_ipv4_cidr_block_association.useast1_secondary_vpc_cidr["${each.value.index_key}-${each.value.associated_vpc_cidr}"].vpc_id : aws_vpc.useast1_vpc_01[each.value.index_key].id
  cidr_block = element( split("|", each.value.subnet_cidr_block), 1)
  availability_zone = lookup( var.useast1_azs, element( split("|", each.value.subnet_cidr_block), 2), "us-east-1d")
  #availability_zone = "us-east-1${lower(element( split("|", each.value.subnet_cidr_block), 2))}"

  tags = merge(
    {Name = element( split("|", each.value.subnet_cidr_block), 0)},
    each.value.network_tags
  )

  
}

#-------------------------------------------------------------#

resource "aws_internet_gateway" "useast1_gw" {
for_each = { for o in local.internet_gateways: o.index_key => o }

  vpc_id = aws_vpc.useast1_vpc_01[each.key].id
  tags = merge(
    {Name = "${each.value.index_key}-igw"},
    each.value.network_tags
  )

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_nat_gateway" "useast1_nat_gw" {
for_each = { for o in local.nat_gateways: "${o.index_key}-${element(split( "|", o.nat_gateway), 0)}" => o}

  allocation_id = aws_eip.useast1_eip["${each.value.index_key}-${element(split( "|", each.value.nat_gateway), 0)}"].allocation_id
  subnet_id     = aws_subnet.useast1_subnets["${each.value.index_key}-${element(split( "|", each.value.nat_gateway), 1)}"].id

  tags = merge(
    {Name = element(split( "|", each.value.nat_gateway), 0)},
    each.value.network_tags
  )

  depends_on = [ 
    aws_eip.useast1_eip,
    aws_subnet.useast1_subnets
   ]

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_eip" "useast1_eip" {
for_each = { for o in local.nat_gateways: "${o.index_key}-${element(split( "|", o.nat_gateway), 0)}" => o}

  tags = merge(
    {Name = "${element(split( "|", each.value.nat_gateway), 0)}-eip" },
    each.value.network_tags
  )

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_route_table" "useast1_route_tables" {
for_each = { for o in local.route_tables: "${o.index_key}-${o.name}" => o}

  vpc_id = aws_vpc.useast1_vpc_01[each.value.index_key].id
  route = []
  tags = merge(
    {Name = each.value.name},
    each.value.network_tags
  )

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_route_table_association" "useast1_rt_associations" {
for_each = { for o in local.rt_associations: "${o.index_key}-${o.rt_name}-${o.cidr}" => o }

  subnet_id      = aws_subnet.useast1_subnets["${each.value.index_key}-${each.value.cidr}"].id
  route_table_id = aws_route_table.useast1_route_tables["${each.value.index_key}-${each.value.rt_name}"].id

  depends_on = [
    aws_subnet.useast1_subnets
  ]

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_route" "useast1_natgw_routes" {
for_each = { for o in local.rt_routes: "${o.index_key}-${o.rt_name}-${o.route}" => o if element(split("|", o.route),0) == "natgw"}

  route_table_id            = aws_route_table.useast1_route_tables["${each.value.index_key}-${each.value.rt_name}"].id
  destination_cidr_block    = element(split("|", each.value.route), 1)
  nat_gateway_id = aws_nat_gateway.useast1_nat_gw["${each.value.index_key}-${element(split("|", each.value.route), 2)}"].id

  depends_on = [
    aws_nat_gateway.useast1_nat_gw
  ]

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_route" "useast1_igw_routes" {
for_each = { for o in local.rt_routes: "${o.index_key}-${o.rt_name}-${o.route}" => o if element(split("|", o.route),0) == "igw"}

  route_table_id            = aws_route_table.useast1_route_tables["${each.value.index_key}-${each.value.rt_name}"].id
  destination_cidr_block    = element(split("|", each.value.route), 1)
  gateway_id = aws_internet_gateway.useast1_gw[each.value.index_key].id

  depends_on = [
    aws_internet_gateway.useast1_gw
  ]

  lifecycle {
    ignore_changes = all
  }
}

#-------------------------------------------------------------#
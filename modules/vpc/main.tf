resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true   
  enable_dns_hostnames = true
  tags = { Name = "main_vpc" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "public_subnet_${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "private_subnet_${count.index + 1}" }
}

data "aws_availability_zones" "available" {}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

#resource "aws_route_table_association" "public_subnet_assoc" {
#  count          = length(aws_subnet.private)
#  subnet_id      = aws_subnet.private[count.index].id
#  route_table_id = aws_route_table.public_rt.id
#}


# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

# Create the NAT Gateway in your public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

# Create a route table for private subnets to use the NAT Gateway for outbound traffic
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Associate the private route table with your private subnets
resource "aws_route_table_association" "private" {
  #count          = length(var.private_subnet_ids)
  count           = length(aws_subnet.private)
  #subnet_id      = var.private_subnet_ids[count.index]
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


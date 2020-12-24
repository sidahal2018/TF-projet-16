provider "aws" {
  region = var.region
}
# Create VPC
resource "aws_vpc" "vpcname" {
     cidr_block = var.vpc_cidr
     tags = {
       Name = "myvpc"
     }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
    count = length(data.aws_availability_zones.azs.names)  # retuns the size of the list
    availability_zone = element(data.aws_availability_zones.azs.names, count.index)
    vpc_id = aws_vpc.vpcname.id
    cidr_block = element(var.public_subnets_cidr,count.index) #dynamically picks 1 cidr at a time

    tags ={
      Name = "subnet"
    }

}

resource "aws_subnet" "private_subnets" {
    count = length(data.aws_availability_zones.azs.names)  # retuns the size of the list
    availability_zone = element(data.aws_availability_zones.azs.names, count.index)
    vpc_id = aws_vpc.vpcname.id
    cidr_block = element(var.private_subnets_cidr,count.index) # dynamically picks 1 cidr at a time

    tags ={
      Name = var.private_subnet_name
    }

}

# Internet gateWay
 resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.vpcname.id

   tags= {
       Name = "IGW"
   }
 }
 

# Route Table and and attched Internet gate way
resource "aws_route_table" "Public_RT" {
    vpc_id = aws_vpc.vpcname.id

    route {
      cidr_block = ["0.0.0.0/0"]
      gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
            Name = "PublicRT"
        }
    }


# Route table association with public subnets
resource "aws_route_table_association" "public_association" {
count = length(var.public_subnets_cidr)
subnet_id = element(aws_subnet.public_subnets.*.id, count.index)
route_table_id = aws_route_table.Public_RT.id

}
resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.vpcname.id
  tags = {
   Name = "private_route_table"
  }
}

# Route table association with private  subnets

resource "aws_route_table_association" "private_association" {
count = length(var.private_subnets_cidr)
subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
route_table_id = aws_route_table.Public_RT.id
}

# create NAT gateway

 resource "aws_nat_gateway" "nat" {
 allocation_id = aws_eip.elasticeip.id
 subnet_id = aws_subnet.public_subnets[0].id
 tags = {
   Name = "NAT-gateway"
 }
   
 }
 resource "aws_route" "nate-gw-route" {
     route_table_id = aws_route_table.Private_RT.id
     nat_gateway_id = aws_nat_gateway.nat.id
     destination_cidr_block = "0.0.0.0/0"
   
 }
 




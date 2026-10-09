#vpc
resource "aws_vpc" "demovpc" {
    cidr_block="11.0.0.0/16"
    instance_tenancy="default"
    tags={
        Name="Learn-vpc"
    }
}
#private subnet
resource "aws_subnet" "pri-sub" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "11.0.2.0/24"

  tags = {
    Name = "Private Subnet"
  }
}
#public subnet
resource "aws_subnet" "pub-sub" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "11.0.1.0/24"

  tags = {
    Name = "Public Subnet"
  }
}
#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demovpc.id

  tags = {
    Name = "learn-IGW"
  }
}

#Route Table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}
#Subnet and Route table Association
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.example.id
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "public_1c" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.2.0/24"
}

resource "aws_subnet" "private_1a" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.10.0/24"
}

resource "aws_subnet" "private_1c" {
  vpc_id = aws_vpc.vpc.id

  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.20.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat_1a" {
  vpc = true
}

resource "aws_nat_gateway" "nat_1a" {
  subnet_id     = aws_subnet.public_1a.id
  allocation_id = aws_eip.nat_1a.id
}

resource "aws_eip" "nat_1c" {
  vpc = true
}

resource "aws_nat_gateway" "nat_1c" {
  subnet_id     = aws_subnet.public_1c.id
  allocation_id = aws_eip.nat_1c.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "private_1a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_1a.id
  nat_gateway_id         = aws_nat_gateway.nat_1a.id
}

resource "aws_route" "private_1c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_1c.id
  nat_gateway_id         = aws_nat_gateway.nat_1c.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1c.id
}

resource "aws_security_group" "endpoint_security_group" {
  name   = "endpoint_security_group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = false
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = false
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  service_name       = "com.amazonaws.ap-northeast-1.secretsmanager"
  security_group_ids = [aws_security_group.endpoint_security_group.id]
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "ssm" {
  service_name       = "com.amazonaws.ap-northeast-1.ssm"
  security_group_ids = [aws_security_group.endpoint_security_group.id]
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "ssmmessages" {
  service_name       = "com.amazonaws.ap-northeast-1.ssmmessages"
  security_group_ids = [aws_security_group.endpoint_security_group.id]
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "ec2messages" {
  service_name       = "com.amazonaws.ap-northeast-1.ec2messages"
  security_group_ids = [aws_security_group.endpoint_security_group.id]
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}

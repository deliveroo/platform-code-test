resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet_apps_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-apps-a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-apps-a"
  }
}

resource "aws_route_table" "subnet_route_table_apps" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main-apps"
  }
}

resource "aws_route_table_association" "subnet_apps_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_apps_a.id
  route_table_id = aws_route_table.subnet_route_table_apps.id
}

resource "aws_subnet" "subnet_dbs_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-dbs-a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-dbs-a"
  }
}

resource "aws_route_table" "subne_route_table_dbs" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main-dbs"
  }
}

resource "aws_route_table_association" "subnet_dbs_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_dbs_a.id
  route_table_id = aws_route_table.subne_route_table_dbs.id
}

resource "aws_subnet" "subnet_public_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-public-a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-public-a"
  }
}

resource "aws_route_table" "subnet_route_table_public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main-public"
  }
}

resource "aws_route_table_association" "subnet_public_a-route-table-association" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.subnet_route_table_public.id
}

resource "aws_route" "subnet_route_public_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
  route_table_id         = aws_route_table.subnet_route_table_public.id
}

# NAT

# Single NAT to save dollar
resource "aws_eip" "nat_main" {
  domain = "vpc"

  tags = {
    Name = "nat_main"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_main.id
  subnet_id     = aws_subnet.subnet_apps_a.id

  tags = {
    Name = "nat_main"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet_apps_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet-cidr-apps-a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-apps-a"
  }
}

resource "aws_route_table" "subnet_route_table_apps" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-apps"
  }
}

resource "aws_route_table_association" "subnet_apps_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_apps_a.id
  route_table_id = aws_route_table.subnet_route_table_apps.id
}

resource "aws_subnet" "subnet_dbs_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet-cidr-dbs-a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-dbs-a"
  }
}

resource "aws_route_table" "subne_route_table_dbs" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-dbs"
  }
}

resource "aws_route_table_association" "subnet_dbs_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_dbs_a.id
  route_table_id = aws_route_table.subne_route_table_dbs.id
}

resource "aws_subnet" "subnet_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet-cidr-public-a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-public-a"
  }
}

resource "aws_subnet" "subnet_public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet-cidr-public-b
  availability_zone = "${var.region}b"

  tags = {
    Name = "main-public-b"
  }
}

resource "aws_subnet" "subnet_public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet-cidr-public-c
  availability_zone = "${var.region}c"

  tags = {
    Name = "main-public-c"
  }
}

resource "aws_route_table" "subnet_route_table_public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-public"
  }
}

resource "aws_route_table_association" "subnet_public_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.subnet_route_table_public.id
}

resource "aws_route_table_association" "subnet_public_b_route_table_association" {
  subnet_id      = aws_subnet.subnet_public_b.id
  route_table_id = aws_route_table.subnet_route_table_public.id
}
resource "aws_route_table_association" "subnet_public_c_route_table_association" {
  subnet_id      = aws_subnet.subnet_public_c.id
  route_table_id = aws_route_table.subnet_route_table_public.id
}

resource "aws_route" "subnet_route_table_public_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
  route_table_id         = aws_route_table.subnet_route_table_public.id
}

# NAT

# Single NAT to save dollar
resource "aws_eip" "nat_main" {
  domain = "vpc"

  tags = {
    Name = "nat-main"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_main.id
  subnet_id     = aws_subnet.subnet_public_a.id

  tags = {
    Name = "nat-main"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "subnet_route_table_apps_nat" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
  route_table_id         = aws_route_table.subnet_route_table_apps.id
}

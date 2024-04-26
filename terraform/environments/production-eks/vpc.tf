resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
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

# Apps Subnets

resource "aws_subnet" "subnet_apps_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_apps_a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-apps-a"
  }
}

resource "aws_subnet" "subnet_apps_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_apps_b
  availability_zone = "${var.region}b"

  tags = {
    Name = "main-apps-b"
  }
}

resource "aws_subnet" "subnet_apps_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_apps_c
  availability_zone = "${var.region}c"

  tags = {
    Name = "main-apps-c"
  }
}

resource "aws_route_table" "subnet_route_table_apps" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-apps"
  }
}

resource "aws_route_table_association" "subnet_apps_a_association" {
  subnet_id      = aws_subnet.subnet_apps_a.id
  route_table_id = aws_route_table.subnet_route_table_apps.id
}

resource "aws_route_table_association" "subnet_apps_b_association" {
  subnet_id      = aws_subnet.subnet_apps_b.id
  route_table_id = aws_route_table.subnet_route_table_apps.id
}

resource "aws_route_table_association" "subnet_apps_c_association" {
  subnet_id      = aws_subnet.subnet_apps_c.id
  route_table_id = aws_route_table.subnet_route_table_apps.id
}

# DB Subnets

resource "aws_subnet" "subnet_dbs_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_dbs_a
  availability_zone = "${var.region}a"

  tags = {
    Name = "main-dbs-a"
  }
}

resource "aws_subnet" "subnet_dbs_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_dbs_b
  availability_zone = "${var.region}b"

  tags = {
    Name = "main-dbs-b"
  }
}

resource "aws_subnet" "subnet_dbs_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_dbs_c
  availability_zone = "${var.region}c"

  tags = {
    Name = "main-dbs-c"
  }
}

resource "aws_route_table" "subne_route_table_dbs" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-dbs"
  }
}

resource "aws_route_table_association" "subnet_dbs_a_association" {
  subnet_id      = aws_subnet.subnet_dbs_a.id
  route_table_id = aws_route_table.subne_route_table_dbs.id
}

resource "aws_route_table_association" "subnet_dbs_b_association" {
  subnet_id      = aws_subnet.subnet_dbs_b.id
  route_table_id = aws_route_table.subne_route_table_dbs.id
}

resource "aws_route_table_association" "subnet_dbs_c_association" {
  subnet_id      = aws_subnet.subnet_dbs_c.id
  route_table_id = aws_route_table.subne_route_table_dbs.id
}

# Public subnets
resource "aws_subnet" "subnet_public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_public_a
  availability_zone = "${var.region}a"

  tags = {
    Name                     = "main-public-a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "subnet_public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_public_b
  availability_zone = "${var.region}b"

  tags = {
    Name                     = "main-public-b"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "subnet_route_table_public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-public"
  }
}

resource "aws_route_table_association" "subnet_public_a_association" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.subnet_route_table_public.id
}

resource "aws_route_table_association" "subnet_public_b_association" {
  subnet_id      = aws_subnet.subnet_public_b.id
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

# NACL

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 900
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 900
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "main-public"
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "-1"
    rule_no    = 800
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "tcp"
    rule_no    = 900
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "-1"
    rule_no    = 800
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 900
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "main-private"
  }
}

resource "aws_network_acl_association" "subnet_apps_a_association" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.subnet_apps_a.id
}

resource "aws_network_acl_association" "subnet_apps_b_association" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.subnet_apps_b.id
}

resource "aws_network_acl_association" "subnet_apps_c_association" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.subnet_apps_c.id
}

resource "aws_network_acl_association" "subnet_dbs_a_association" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.subnet_dbs_a.id
}

resource "aws_network_acl_association" "subnet_dbs_b_association" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.subnet_dbs_b.id
}

resource "aws_network_acl_association" "subnet_dbs_c_association" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.subnet_dbs_c.id
}

resource "aws_network_acl_association" "subnet_public_a_association" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.subnet_public_a.id
}

resource "aws_network_acl_association" "subnet_public_b_association" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.subnet_public_b.id
}

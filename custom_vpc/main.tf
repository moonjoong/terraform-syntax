resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "public_subnet" {
  count             = var.env == "dev" ? 1 : 0
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = ap-east-1a
  tags = {
    Name = "public_subnet_${var.env}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = ap-east-1a
  tags = {
    Name = "private_subnet_${var.env}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "hagaramit_igw${var.env}"
  }
}

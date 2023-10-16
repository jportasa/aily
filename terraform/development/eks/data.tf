data "aws_vpc" "aily_vpc" {
  filter {
    name   = "tag:Name"
    values = ["aily-vpc"]
  }
}

data "aws_subnet" "aily_vpc_public_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["aily-vpc-public-us-east-1a"]
  }
}

data "aws_subnet" "aily_vpc_public_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["aily-vpc-public-us-east-1b"]
  }
}

data "aws_subnet" "aily_vpc_private_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["aily-vpc-private-us-east-1a"]
  }
}

data "aws_subnet" "aily_vpc_private_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["aily-vpc-private-us-east-1b"]
  }
}
# Configure aws provider
# based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  #profile = "Admin"
}

# configure vpc
# based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "dep5_1_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    vpc_name = var.vpc_name
  }
}

# cofigure subnet
# based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# https://developer.hashicorp.com/terraform/language/meta-arguments/count
resource "aws_subnet" "dep5_1_pubsubnet1" {
  vpc_id                  = aws_vpc.dep5_1_vpc.id
  cidr_block              = var.subnet1_cidr_block
  availability_zone       = var.pub_subnet1
  map_public_ip_on_launch = true

  tags = {
    subnet1_name = var.subnet1_name
  }
}

resource "aws_subnet" "dep5_1_pubsubnet2" {
  vpc_id                  = aws_vpc.dep5_1_vpc.id
  cidr_block              = var.subnet2_cidr_block
  availability_zone       = var.pub_subnet2
  map_public_ip_on_launch = true

  tags = {
    subnet2_name = var.subnet2_name
  }
}

# configure internet gateway
# based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "dep5_1_igw" {
  vpc_id = aws_vpc.dep5_1_vpc.id

  tags = {
    "igw_name" = var.igw_name
  }
}

# configure route table
# based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "dep5_1_rte_tbl" {
  vpc_id = aws_vpc.dep5_1_vpc.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.dep5_1_igw.id # associates route table with igw
  }

  tags = {
    dep5_route_table = var.dep5_1_route_table
  }
}

# configure route table association - subnet1
resource "aws_route_table_association" "dep5_1_pubsubnet1_rta" {
  subnet_id      = aws_subnet.dep5_1_pubsubnet1.id
  route_table_id = aws_route_table.dep5_1_rte_tbl.id
}

# configure route table association - subnet2
resource "aws_route_table_association" "dep5_1_pubsubnet2_rta" {
  subnet_id      = aws_subnet.dep5_1_pubsubnet2.id
  route_table_id = aws_route_table.dep5_1_rte_tbl.id
}

# configure dep5_web_server instance
# based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "dep5_1_jenkins_main_server" {

  depends_on = [aws_internet_gateway.dep5_1_igw]

  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.dep5_1_pubsubnet1.id # main jenkins
  vpc_security_group_ids      = [aws_security_group.dep5_1_allow_traffic_pubsubnet1.id]

  user_data = file("jenkins_installation.sh")

  tags = {
    "web_server" : var.jenkins_main_server
  }
}

# configure dep5_app_server instance
resource "aws_instance" "dep5_1_app_server" {
  depends_on = [aws_internet_gateway.dep5_1_igw]

  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.dep5_1_pubsubnet2.id # applications with jenkins main on subnet 1
  vpc_security_group_ids      = [aws_security_group.dep5_1_allow_traffic_pubsubnet2.id]

  user_data = file("configure_python.sh")

  tags = {
    "app_server" : var.app_server
  }
}

resource "aws_instance" "dep5_1_jenkins_agent_server" {

  depends_on = [aws_internet_gateway.dep5_1_igw]

  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.dep5_1_pubsubnet1.id # jenkins agent on subnet2
  vpc_security_group_ids      = [aws_security_group.dep5_1_allow_traffic_pubsubnet1.id]

  user_data = file("configure_python.sh")

  tags = {
    "agent_server" : var.jenkins_agent_server
  }
}

# configure security group
# based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "dep5_1_allow_traffic_pubsubnet1" {
  vpc_id = aws_vpc.dep5_1_vpc.id

  ingress {
    description = "allow incoming SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow incoming traffic on port 8080"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow incoming traffic on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "sg_name" : var.sg_name
    "terraform" : "true"
  }
}

resource "aws_security_group" "dep5_1_allow_traffic_pubsubnet2" {
  vpc_id = aws_vpc.dep5_1_vpc.id

  ingress {
    description = "allow incoming SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow incoming traffic on port 8000 "
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow incoming traffic on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "sg_name" : var.sg_name
    "terraform" : "true"
  }
}
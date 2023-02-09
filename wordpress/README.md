
# Terraform AWS

[TOC]

[https://spacelift.io/blog/terraform-aws-vpc](https://)
blast-radius

# VPC 
Basic VPC with 
## variables.tf
```tf
variable "any" {
  default = "0.0.0.0/0"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.0.0/24", "10.0.1.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24","10.0.3.0/24"]
}
```

## vpc_main.tf 

```tf
#VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/22"
  tags = {
    Name = "marc-vpc"
  }
}

#AVAILIBLITY ZONES
data "aws_availability_zones" "available" {}


#SUBNETS
resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2a"
  tags = {
    Name = "marc-public1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2b"
  tags = {
    Name = "marc-public2"
  }
}
resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2a"
  tags = {
    Name = "marc-private1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2b"
  tags = {
    Name = "marc-private2"
  }
}
#Simplificado
/*resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "marc-public${count.index + 1}"
  }
}*/

/*resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "marc-private${count.index + 1}"
  }
}*/

#INTERNET GATEWAY
resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "marc-igw"
  }
}


#ROUTE TABLE
resource "aws_route" "route" {
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gateway.id
}

#TABLA DE RUTAS
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id

  }
  route {
    cidr_block = "10.0.0.0/22"
    gateway_id = "localhost"
  }
  tags = {
    "Name" = "marc-rtb-public"
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.private1.id
}
```

## security_groups.tf
```tf
#SECURITY GROUPS
resource "aws_security_group" "free" {
  name        = "free"
  description = "Permite todo el tráfico"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["${var.any}"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["${var.any}"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "free"
  }
}
```
# VPN

# EC2 (wordpress) and RDS (mysql)
Launch an EC2 instance and a RDS instance with terraform. Simple sample.

## provider.tf

```tf
provider "aws" {
  profile    = "default" 
  region     = "us-east-1"
  access_key = "default"
  secret_key = "default"
  token      = "default"
}

```

## variable.tf
```tf
variable "ssh_key" {
  type = string
  default = "public_ssh_key"
  description = "SSH public key for EC2 connection"
}

```
## instance_wordpress.tf
```tf
resource "aws_instance" "wp" {
    ami           = "ami-0b5eea76982371e91" #Amazon Linux 2 Kernel 5.10 AMI 2.0.20221210.1 x86_64 HVM gp2
    instance_type = "t2.micro"
    key_name      = "aws_key_marc"
    vpc_security_group_ids = [aws_security_group.wp.id,aws_security_group.bbdd_ec2_conncetion.id]    
    tags = {
      "Name" = "wp_marc"
    }
}
```
## rds_mysql.tf
```tf
resource "aws_db_instance" "bbdd" {
    identifier = "msaezbbdd"
    db_name = "wordpress"
    engine = "mysql"
    username = "admin"
    password = "password"
    instance_class = "db.t2.micro"
    allocated_storage = 20
    vpc_security_group_ids = [aws_security_group.bbdd_ec2_conncetion.id]
    skip_final_snapshot = true
}
```

## security_groups.tf
```tf
resource "aws_security_group" "wp" {
  egress {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
 
  ingress                = [
    {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "SSH connection"
      from_port        = 22
      protocol         = "tcp"
      security_groups  = []
      to_port          = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
   },
   {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "HTTP connection"
      from_port        = 80
      protocol         = "tcp"
      security_groups  = []
      to_port          = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
   },
   {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "HTTPs connection"
      from_port        = 443
      protocol         = "tcp"
      security_groups  = []
      to_port          = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
   }
   ]
}

resource "aws_security_group" "bbdd_ec2_connection" {
 
  ingress                = [
    {
      cidr_blocks      = [ "0.0.0.0/0" ]
      description      = "MYSQL/Aurora connection"
      from_port        = 3306
      protocol         = "tcp"
      security_groups  = []
      to_port          = 3306
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
   }
   ]
}
```
## key_pair.tf
```tf
resource "aws_key_pair" "marc" {
  key_name   = "aws_key_marc"
  public_key = var.ssh_key
}

```

## outputs.tf
```tf
output "IP_EC2" {
  value= aws_instance.wp.public_ip
}

output "endpoint_BBDD" {
  value= aws_db_instance.bbdd.endpoint
}
```

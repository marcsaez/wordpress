#----------RDS----------
resource "aws_db_instance" "bbdd" {
    identifier = "msaezbbdd"
    db_name = "wordpress"
    engine = "mysql"
    username = "admin"
    password = "p4ssword!"
    instance_class = "db.t2.micro"
    allocated_storage = 20
    vpc_security_group_ids = [aws_security_group.bbdd_ec2_conncetion.id]
    skip_final_snapshot = true
    tags = {
      "Name" = "mysql_marc"
    }
}

resource "aws_instance" "wp" {
    ami           = "ami-0b5eea76982371e91" #Amazon Linux 2 Kernel 5.10 AMI 2.0.20221210.1 x86_64 HVM gp2
    instance_type = "t2.micro"
    key_name      = "aws_key_marc"
    vpc_security_group_ids = [aws_security_group.wp.id,aws_security_group.bbdd_ec2_conncetion.id]    
    tags = {
      "Name" = "wp_marc"
    }
}

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
   }
   ]
}

resource "aws_security_group" "bbdd_ec2_conncetion" {
 
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

resource "aws_key_pair" "marc" {
  key_name   = "aws_key_marc"
  public_key = var.ssh_key
}

output "IP_EC2" {
  value= aws_instance.wp.public_ip
}

output "endpoint_BBDD" {
  value= aws_db_instance.bbdd.endpoint
}

#---------------SSH PUBLIC KEY---------------
resource "aws_key_pair" "marc" {
  key_name   = "${var.name}aws_key"
  public_key = var.ssh_key
}

#---------------RDS---------------
resource "aws_db_instance" "bbdd" {
    identifier = "${var.name}bbdd"
    db_name = var.db_name
    engine = "mysql"
    username = var.db_admin
    password = var.db_pass
    instance_class = var.db_type
    allocated_storage = var.db_store
    vpc_security_group_ids = [aws_security_group.bbdd_ec2_conncetion.id]
    skip_final_snapshot = true
    tags = {
      "Name" = "${var.name}mysql"
    }
}

#---------------EC2---------------
resource "aws_instance" "wp" {
    ami           = data.aws_ami.al2.id 
    instance_type = var.ec2_type
    key_name      = "${var.name}aws_key"
    vpc_security_group_ids = [aws_security_group.wp.id,aws_security_group.bbdd_ec2_conncetion.id]
    user_data_base64 = base64encode(data.template_file.cloud-init-config.rendered)
    provisioner "remote-exec" {
      inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
      "echo 'Wordpress ready!'",
      ]
    } 
    tags = {
      "Name" = "${var.name}wp"
    }
    depends_on = [
      aws_db_instance.bbdd
    ]
}

#---------------SG EC2---------------
resource "aws_security_group" "wp" {
  name = "${var.name}sg-wp"
  egress {
      cidr_blocks      = [ "0.0.0.0/0" ]
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

#---------------SG RDS---------------
resource "aws_security_group" "bbdd_ec2_conncetion" {
  name = "${var.name}sg-db-connection"
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

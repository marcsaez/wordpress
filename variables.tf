# NECESSARY
#-----------
variable "region" { default = "us-east-1" }
variable "access_key" { default = "ACCES KEY NECESSARY" }
variable "secret_key" { default = "SECRET KEY NECESSARY" }
variable "ssh_key" { default = "SSH PUBLIC KEY NECESSARY" }

# OTHERS
variable "name" { default = "msaez-" }

# RDS
variable "db_name" { default = "wordpress" }
variable "db_admin" { default = "admin" }
variable "db_pass" { default = "password" }
variable "db_type" { default = "db.t2.micro" }
variable "db_store" { default = 20 }

# EC2
variable "ec2_type" { default = "t2.micro"}
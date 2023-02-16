# Ubuntu Server 22.04 AMI (Latest)
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

# CLOD INIT 
data "template_file" "cloud-init-config" {
  template = file("./config/cloud-init.yaml")
  vars = {
    db_endpoint = "${split(":", aws_db_instance.bbdd.endpoint)[0]}"
    db_name     = var.db_name
    db_admin    = var.db_admin
    db_pass     = var.db_pass
    wp_user     = var.wp_user
    wp_pass     = var.wp_pass
  }
}

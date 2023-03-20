output "ip_ec2" {
  value= aws_instance.wp.public_ip
}

output "endpoint_BBDD" {
  value= split(":", aws_db_instance.bbdd.endpoint)[0] #element(split(":",aws_db_instance.bbdd.endpoint),0)
}


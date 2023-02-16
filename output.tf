output "IP_EC2" {
  value= aws_instance.wp.public_ip
}

output "endpoint_BBDD" {
  value= aws_db_instance.bbdd.endpoint #element(split(":",aws_db_instance.bbdd.endpoint),0)
}


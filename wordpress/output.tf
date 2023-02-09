output "IP_EC2" {
  value= aws_instance.wp.public_ip
}

output "endpoint_BBDD" {
  value= aws_db_instance.bbdd.endpoint
}

output "acces" {
  value= var.access_key
}

output "secret" {
  value= var.secret_key
}

data "terraform_remote_state" "main" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

data "template_file" "php" {
  
  vars = {
    key_name = "key_name"
  }
}
# data "template_file" "wp-config" {
#   template = file("./wp-config/wp-config.php")
#   vars = {
#     user     = var.wp_user
#     password = var.wp_pass
#     db       = var.db_name
#     endpoint = data.terraform_remote_state.main.outputs.endpoint_BBDD
#   }
  
# }
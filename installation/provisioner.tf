resource "null_resource" "bbdd" {
  triggers = {
    instance_id = data.terraform_remote_state.main.outputs.ip_ec2
    }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = "${data.terraform_remote_state.main.outputs.ip_ec2}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mysql -h ${data.terraform_remote_state.main.outputs.endpoint_BBDD} --user=admin --password=\"${var.db_pass}\" -e \"CREATE USER 'msaez' IDENTIFIED BY '${var.password}';\"",
      "sudo mysql -h ${data.terraform_remote_state.main.outputs.endpoint_BBDD} --user=admin --password=\"${var.db_pass}\" -e \"GRANT ALL PRIVILEGES ON wordpress.* TO msaez;\"",
      "sudo mysql -h ${data.terraform_remote_state.main.outputs.endpoint_BBDD} --user=admin --password=\"${var.db_pass}\" -e \"FLUSH PRIVILEGES;\""
    ]
  }
}



resource "local_file" "wpconfig" {
  content  = local.php
  filename = "${path.module}/wp-config/wp-config.php"

}

resource "null_resource" "wp-installation" {
  triggers = {
    instance_id = data.terraform_remote_state.main.outputs.ip_ec2
    }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = "${data.terraform_remote_state.main.outputs.ip_ec2}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
  provisioner "file" {
    source = "${path.module}/wp-config/wp-config.php"
    destination = "/home/ubuntu/wp-config.php"
  } 
  provisioner "file" {
    source = "./wp-config/wordpress.conf"
    destination = "/home/ubuntu/wordpress.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "cat ~/wordpress.conf",
      "sudo cp ~/wordpress.conf /etc/apache2/sites-available/wordpress.conf",
      "sudo a2ensite wordpress",
      "sudo a2enmod rewrite",
      "sudo a2dissite 000-default",
      "sudo service apache2 reload",
      "sleep 5",
      "cat ~/wp-config.php",
      "sudo mkdir -p /srv/www",
      "sudo chown www-data: /srv/www",
      "curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www",
      "sudo cp /home/ubuntu/wp-config.php /srv/www/wordpress/wp-config.php"
    ]
  }
  depends_on = [
    null_resource.bbdd
  ]

}
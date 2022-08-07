data "aws_availability_zones" "zones" {
  state = "available"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = var.vpc_id
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "dockercompose" {
  template = file("./tpl/docker-compose.tpl")

  vars = {
    dbhost        = aws_db_instance.wordpressdb.endpoint
    dbuser        = aws_db_instance.wordpressdb.username
    dbpassword    = aws_db_instance.wordpressdb.password
    dbname        = aws_db_instance.wordpressdb.database_name
    external_port = var.wordpress_external_port
  }
}

data "template_file" "nginx_conf" {
  template = file("./tpl/server-conf.tpl")

  vars = {
    external_port = var.wordpress_external_port
   # url_endpoint  = aws_instance.wordpress.public_dns
  }
}

data "template_file" "userdata" {
  template = file("./tpl/userdata.tpl")

  vars = {
    dockercompose = data.template_file.dockercompose.rendered
    nginx_conf    = data.template_file.nginx_conf.rendered
  }

}
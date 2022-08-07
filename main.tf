resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = sort(data.aws_subnet_ids.subnets.ids)[0]
  security_groups             = [aws_security_group.ec2_secgrp.id]
  iam_instance_profile        = "aws-cli-user"
  user_data                   = data.template_file.userdata.rendered

  tags = merge(local.tags, {
    Name = "wordpress-instance"
  })
}

resource "aws_db_instance" "wordpressdb" {
  allocated_storage    = 10
  engine               = "mariadb"
  engine_version       = "10.6"
  instance_class       = var.rds_instance_type
  name                 = aws_ssm_parameter.dbname.value
  username             = aws_ssm_parameter.dbuser.value
  password             = aws_ssm_parameter.dbpassword.value
  #parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

resource "aws_ssm_parameter" "dbname" {
  name  = "/app/wordpress/DATABASE_NAME"
  type  = "String"
  value = var.database_name
}

resource "aws_ssm_parameter" "dbuser" {
  name  = "/app/wordpress/DATABASE_MASTER_USERNAME"
  type  = "String"
  value = var.database_master_username
}

resource "aws_ssm_parameter" "dbpassword" {
  name  = "/app/wordpress/DATABASE_MASTER_PASSWORD"
  type  = "SecureString"
  value = random_password.password.result
}

resource "random_password" "password" {
  length           = 18
  special          = true
  override_special = "_%@"
}



resource "aws_security_group" "ec2_secgrp" {
  name        = "wordpress-instance-secgrp"
  description = "wordpress instance secgrp"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.wordpress_external_port
    to_port     = var.wordpress_external_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags

}
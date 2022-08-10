
#Create EC2 Instance
resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = sort(data.aws_subnet_ids.subnets.ids)[1]
  security_groups             = [aws_security_group.ec2_secgrp.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.id
  user_data                   = data.template_file.userdata.rendered

  tags = merge(local.tags, {
    Name = "wordpress-instance"
  })
}

#Create RDB instance
resource "aws_db_instance" "wordpressdb" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.rds_instance_type
  db_name                = aws_ssm_parameter.dbname.value
  username               = aws_ssm_parameter.dbuser.value
  password               = aws_ssm_parameter.dbpassword.value
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.id
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_secgrp.id]

  tags = merge(local.tags, {
    Name = "wordpressdb-instance"
  })


}

#SSM store for DB user
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

#Randomised Password for DB user
resource "random_password" "password" {
  length           = 18
  special          = true
  override_special = "_%@"
}

resource "aws_db_subnet_group" "dbsubnet" {
  name        = "wordpress-subnet"
  description = "wordpress prefix group"
  subnet_ids  = data.aws_subnet_ids.subnets.ids

  tags = merge(local.tags, {
    Name = "wordpress-subnet"
  })

}

# RDS  ACL & Sec group
resource "aws_security_group" "rds_secgrp" {
  name        = "wordpress db allow"
  description = "RDS secgrp"
  vpc_id      = var.vpc_id

  ingress {
    description = "allow VPC prefixes only "
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block] #["0.0.0.0/0"] 
  }

  tags = merge(local.tags, {
    Name = "db-secgrp"
  })

}

#IAM role for Session Manager, keyless for testing
resource "aws_iam_role" "ec2role" {
  name = "ec2forssm"

  assume_role_policy = <<EOF
   {
     "Version": "2012-10-17",
     "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"

                },
                "Effect": "Allow",
                "Sid": ""

            }
        ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ec2policy" {
  role       = aws_iam_role.ec2role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2role.name

}



# EC2  ACL & Sec group
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

  tags = merge(local.tags, {
    Name = "ec2-secgrp"
  })


}

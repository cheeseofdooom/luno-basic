# EC2 public dns
output "public_dns" {
  value = aws_instance.wordpress.public_dns
}

# EC2 public address
output "public_ip" {
  value = aws_instance.wordpress.public_ip
}


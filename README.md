# luno-basic-alb-ssl

Please adjust input.tfvars file with your VPC ID and Region. DB and endpoint vars can be changed optionally.

Note: Due to testing on my current free tier VPC which already had custom subnet allocations I had to sort through subnets for EC2 allocation. For my working config second subet was required "sort(data.aws_subnet_ids.subnets.ids)[1]"

With a default VPC "sort(data.aws_subnet_ids.subnets.ids)[0]" should be used. 

Create new Terraform Workspace if required

Run:
terraform plan -var-file input.tfvars -out output.tfplan  
terraform apply output.tfplan  

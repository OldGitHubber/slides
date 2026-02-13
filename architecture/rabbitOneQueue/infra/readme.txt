Create 2 vms and deploy rabbitMQ and producer and consumer

Create vnet
terraform apply -var-file="vnet.tfvars" -auto-approve

Create producer vm
terraform apply -var-file="prod.tfvars" -auto-approve

Create consumer vm
terraform apply -var-file="cons.tfvars" -auto-approve


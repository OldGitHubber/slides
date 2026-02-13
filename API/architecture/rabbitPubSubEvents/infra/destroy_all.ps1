# Start-job runs tasks in background and in parallel
# Destroy all apps and rabbitMQ but not the networks they are in
# Set-Location is powershell change dir ie cd
Start-Job { Set-Location ./app1; terraform destroy -auto-approve }
Start-Job { Set-Location ./app2; terraform destroy -auto-approve }
Start-Job { Set-Location ./app3; terraform destroy -auto-approve }
Start-Job { Set-Location ./RabbitMQ; terraform destroy -auto-approve }

# Wait for all parallel jobs to finish then dstroy the networks
# wait-job will wait for listed - in this case all
Wait-Job *

# Destroy VNet last
Set-Location ./vnet
terraform destroy -auto-approve

# Go back the the start dir
Set-Location ..
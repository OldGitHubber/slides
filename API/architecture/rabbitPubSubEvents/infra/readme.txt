Make sure the onedrive base dir is correct in all tfvars. Use echo $Env:OneDrive to find out
If one is right they all will be. Usually c:... but I sometimes use D:...

Create the VNet first

Individually create each app and rabbitMQ

Or

run ./create_all.ps1   # to build everything at once
run ./destroy_all.ps1  # to - you know ...

Create will output all the IP addresses ets in files in the infra_details dir 
And outputs them all to the screen at the end




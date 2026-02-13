Host bastion
    HostName 20.254.224.199
    User tony
    IdentityFile C:/key/az.pem
    IdentitiesOnly yes # Only try to connect with the key in the identity file


Host app1
    HostName 10.0.1.4
    User tony
    IdentityFile C:/key/az.pem
    ProxyJump bastion
    IdentitiesOnly yes

Host app2
    HostName 10.0.1.5
    User tony
    IdentityFile C:/key/az.pem
    ProxyJump bastion
    IdentitiesOnly yes

Host app3
    HostName 10.0.1.6
    User tony
    IdentityFile C:/key/az.pem
    ProxyJump bastion
    IdentitiesOnly yes

Host rabbitmq
    HostName 10.0.1.7
    User tony
    IdentityFile C:/key/az.pem
    ProxyJump bastion
    IdentitiesOnly yes





Objective
=========
Illustrate async messaging and event messaging
Use app2 to submit a PC component either from the list or type one in
This will be sent to a queue as a producer and app1 is the consumer
app1 is the system's master data store or the system of record (SoR) i.e.
it's Authoritative: It holds the official, most accurate version of the data

App1 checks the provided component against the database (a file in this case) and
if the item already exists, it is ignored. Otherwise, it inserts the component into the database (file)

As the database has been updated, the SoR needs to keep other relevant microservices up to date so
it publishes an updated data event to all subscribers, giving them the new data

The subscribers, app2 and app3 update their local cached copy in their database (a file in this case) so
callers to its API for the list of components will receive an up to date copy. This is illustrated in
this example by console logs and by populating dropdown menus 

If the SoR fails, the other microservices have an up to date copy of the data so are independent of the 
SoR so continue to operate. Any new components added by App2 will be queued util the SoR (app1) come back up

Of course, other microservices will also not see the changes made by app2 either until SoR comes back then they
will all synchronise the changes

Replace the file in app1 with a database


Start RabbitMQ
==============

cd rabbitmq
docker-compose up -d
Visit http://localhost:15672 (admin/admin)

Start apps in VSCode
====================
Use the launch configurations to launch individually or all at once

Operation
=========
Delete any ./data/components.json files in app2 and app3 as app1 will start from zero and it is the SoR
Enter something in app2
review the console messages to see it do its thing
check the content of the dropdowns

Remove the startup policy for app1
execute /killme on app1
add some more stuff from app2
check that app3 is not updated
restart app1 and check it and all apps are updated with the changes

reapply startup policy and show it's hardly noticed that it failed after a kill order

Containerise
============
Make sure there are no containers running and no attached volumes other than the rabbit anonymous volume
Build App2 container remembering to use host.docker.internal in the compose connection string
Check it will put a message on the queue

Build App1 container
Check it consumes the pending message from the queue

Build app3 container
Check it consumes the pending message from the queue

Deploy to cloud
===============
If using portal:
Create 4 VMs using free B1S
Install docker on each
Make sure they are all in the same vnet (jst keep them in the same resource group)
copy the compose file for rabbit mq to a vm and start it

make sure the app1 to app3 compose files point to the private IP of the rabbitmq vm
Push all the images for app1 to 3
login to each vm and start the containers
Each is available at the public IP

If using terraform:
create the vnet first from the /infra/vnet dir and terraform apply --auto-approve
Then do the same for each of the VMs for app1 to app3
These will build the vms and deploy the compose files and start the containers

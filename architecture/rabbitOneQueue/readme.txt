For VScode demo and debugging
=============================
Need to install the rabbit mq message broker. Just use a container.
go into producer folder and 
  docker compose up -d --build
THis will build rabbit with the env vars in compose. It will also build the producer container but don't care about that yet
In debug mode, run both producer and consumer using the launch script

Consumer illustrates constant queue consumption and individual message consumption
For individual, comment out the line startMsgListener(gChannel, QUEUE_NAME)  in the consumer or it will consume all 
Then use 
localhost:3000/rand?cat=computer&num=5 to add 5 messages to the queue
http://localhost:15672 in the browser to look at the queue
localhost:3001/get-msg to get a single message from the queue and watch the messages go down and delivered to the caller
Remove the comment to show all messages consumed

For local containers
====================
Producer is already running
Go into consumer dir and build its container
  docker compose up -d --build
These containers are on separate docker networks so need to be connected to each other with a network bridge
   Follow instructions on the slide
   Get the network names with docker network ls - mine are called producer_net and consumer_default
   docker network connect producer_net consumer
   docker network connect consumer_default producer
If you want to check the containers are connected Then
   docker network inspect then look for container and they should both be listed

Use same endpoints but use 4000 and 4001 as ports

For cloud
=========
use terraform rabbitOneQueue in \demos\architecture
Check in consumer.js if startMsgListener(gChannel, QUEUE_NAME) is commented out. If so, it's compiled with single request API
Make sure - RMQ_HOST=rabbitmq used for local containers is changed to - RMQ_HOST=10.0.1.8 in consumer compose to connect to producer

Follow readme.txt in rabbitOneQueue in \demos\architecture to build the infra and deploy the apps and broker

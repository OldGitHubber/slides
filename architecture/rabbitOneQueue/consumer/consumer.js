const express = require('express')
const app = express()
const amqp = require('amqplib') // Documentation here: https://www.npmjs.com/package/amqp

const APP_CONSUMER_PORT = 3001
const QUEUE_NAME = 'computer'
const RMQ_HOST = process.env.RMQ_HOST || 'localhost'
let gConnection  // File scope so functions can use them. TCP connection to the broker
let gChannel     // One (there can be more) channel multiplexed on the connection

// An alternative way to pass connection string
const conStr = {
  hostname: RMQ_HOST,
  port: 5672,
  username: 'admin',
  password: 'admin',
  vhost: '/'
}


app.get("/", (req, res) => {
  res.send(`Consumer says: I'm alive ...`)
})

// This endpoint calls a function which illustrates how to get a 
// single message from the queue on request as opposed to using a callback
// which sends messages from the queue as they arrive
app.get('/get-msg', async (req, res) => {
  let msg = await getMessageFromQueue(gChannel, QUEUE_NAME)
  if (msg) {
    res.json(msg)
  } else {
    res.status(204).send('No content')
  }
})

// No http endpoints used. Only using server to support the backend consumer app
const server = app.listen(APP_CONSUMER_PORT, () => console.log(`Listening on port ${APP_CONSUMER_PORT}`))

createQueueConnection(conStr)

// ********* Functions *****************

// Try to create a connection to the broker using the connection string as an object
// If connected, call startMessageListener to register the callback for the queue
async function createQueueConnection(conStr) {
  try {
    const rmq = await createConnection(conStr) // amqplib is promise based 
    console.log(`Connection created using: ${JSON.stringify(conStr, null, 2)}}`)
    gConnection = rmq.connection  // Available if needed for something
    gChannel = rmq.channel
    console.log(`Channel opened on Consumer1`)
// startMsgListener(gChannel, QUEUE_NAME) // Call to start the consumer callback

    // amqplib doesn't support auto reconnect if connection is lost. We could try to 
    // reconnect here, but as we are using containers and persistent queue, just kill
    // the app and let docker restart it
    gConnection.on('error', (err) => {
      terminateApp(err)
    })

    // Event listener here in case connection is closed for some reason
    gConnection.on('close', () => {
      const error = { message: "Connection closed" }
      terminateApp(error)
    })

  }
  catch (err) {
    terminateApp(err)
  }
}

// Create connection and channel and return them to the caller
async function createConnection(conStr) {
  try {
    const connection = await amqp.connect(conStr)    // Create connection
    console.log(`Connected to Rabbitmq cluster`)

    const channel = await connection.createChannel()    // Create channel. Channel can have multiple queues
    console.log(`Channel created. Will connect to queue: ${QUEUE_NAME}`)

    return { connection, channel }

  } catch (err) {
    console.log(`Failed to connect to RabbitMQ`)
    throw err
  }
}

// Get a single message from the queue
// Function startMessage listener registers a callback with the rabbit message broker
// so the broker will call the callback each time a message lands on the queue and pushes the message
// However, in this function, we can read one message at a time from the queue and process it
async function getMessageFromQueue(channel, queue) {
  try {
    const message = await channel.get(queue, { noAck: false }) // noAck false is the default. If true, rabbit needs no ack
    if (message) {
      console.log('Received message:', message.content.toString())
      let msg = JSON.parse(message.content.toString())
      channel.ack(message) // Ack message so it will be removed from the queue. Put this somewhere else to ack when msg is processed
      return (msg)
    } else {
      console.log('No messages in the queue')
      return null
    }
  } catch (error) {
    terminateApp(error) // Fatal so try to restart
  }
}


// Function connects to a queue and registers a callback with the rabbit message broker
// Each time a message lands on the queue, the callback is called by the broker and the message passed as a param. 
// Could for example, just move messages straight into a database, or return to caller or whatever - here I just output them
// Whenever a message is pushed to the queue, this callback is called. This example does nothing other than output the message
// to the console but it illustrates the integration with the queue to build on.
async function startMsgListener(channel, queue) {
  try {
    await channel.assertQueue(queue, { durable: true })  // Connect to durable queue or create if not there
    channel.prefetch(1) // unlimited by default so sends all at once and ack at end. Set to 1 here for individual acks
    // Create callback that will listen for queued message availability. Rabbit will call this function passing the message in the message param
    channel.consume(queue, message => {
      let msg = JSON.parse(message.content.toString()) // Convert binary content to a json string then to a javascript object and assign to msg
      console.log(msg)     // Just output or, say write to a file, database or whatever
      // If writing to database, make the anonymous function async then
      // stuff = await DatabaseCall or whatever
      channel.ack(message) // Ack message so it will be removed from the queue. Don't ack and they stay queued until connection reestablished by consumer restart
    })

  } catch (err) {
    throw err
  }
}


// If needed, this is a function to close the queue connections
async function closeConnection(connection, channel) {
  try {
    await channel.close()
    await connection.close()
    console.log(`Connection and channel closed`)
  } catch (err) {
    console.log(`Failed to close connection. ${err}`)
  }
}

// Basically if anything goes wrong, kill the app and let Docker try to restart it
function terminateApp(error) {
  console.log('Unexpected error: ', error.message ? error.message : error.stack) // Inconsistent error reporting. Not all have .message

  if (gConnection) {
    closeConnection(gConnection, gChannel)
    console.log(`Closing connections`)
  }

  console.log(`Shutting down node server listening on port ${APP_CONSUMER_PORT}`)
  server.close() // Close the http server created with app.listen.
  console.log(`Closing app with process.exit(1)`)
  process.exit(1)  // Exit process with an error to force the container to stop
}
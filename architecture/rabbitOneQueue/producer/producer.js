// RabbitMQ demo. Does nothing fancy - uses defaults. Queue is not set to be durable after container restart
const express = require('express')
const app = express()
const amqp = require("amqplib") // Documentation here: https://www.npmjs.com/package/amqp
app.use(express.json()) // Enable json in POST

const APP_PRODUCER_PORT = 3000
const RMQ_PRODUCER_PORT = 5672
const RMQ_USER_NAME = 'admin'
const RMQ_PASSWORD = 'admin'

const RMQ_HOST = process.env.RMQ_HOST || 'localhost'
let gConnection  // File scope so functions can use them
let gChannel

app.get("/", (req, res) => {
  res.send(`Producer is up`)
})


// Generate some random messages for the queue. Call with:
// localhost:3000/rand to generate one tv type
// localhost:3000/rand?cat=computer&num=5 to generate 5 computer messages on cat queue
app.get("/rand", async (req, res) => {
  let numMsgs = req.query.num ? req.query.num : 1              // At least one message
  let category = req.query.cat ? req.query.cat : 'computer'    // Default to computer

  try {
    await sendRandMsg(gChannel, category, numMsgs)  // Send a random tv message to the queue
    res.status(202).send(`${numMsgs} queued`)       // 202 = accepted. i.e. added to a queue but not necessarily processed yet
  } catch (err) {
    terminateApp(err) // Kill the app and let docker keep restarting it as something bad happened
  }
})



// Post a single bespoke message to the appropriate queue based on the category attribute. e.g.
// {
//   "category": "food",
//   "product": "beans",
//   "cost": 80
// }
app.post("/msg", async (req, res) => {
  try {
    await sendMsg(gChannel, req.body)
    res.sendStatus(202)
  } catch (err) {
    res.status(500).send(err)
  }
})

// app.listen returns an http server. Use this if we need to access the server - e.g. stop it
const server = app.listen(APP_PRODUCER_PORT, console.log(`Listening on port ${APP_PRODUCER_PORT}`))

createQueueConnection() // Try to create a connection to the message broker


/********************** Functions *************************************/

async function createQueueConnection() {
  // An alternative way to pass connection string
  const conStr = `amqp://${RMQ_USER_NAME}:${RMQ_PASSWORD}@${RMQ_HOST}:${RMQ_PRODUCER_PORT}/`
  try {
    console.log(`Trying to connect to RabbitMQ at ${RMQ_HOST}:${RMQ_PRODUCER_PORT}`) // Only give this level of detail away in testing
    const rmq = await createConnection(conStr) // amqplib is promise based so need to initialise it in a function as await only works in an async function
    gConnection = rmq.connection  // Globally available in the file for other functions to use if needed
    gChannel = rmq.channel

    gConnection.on('error', (err) => {
      terminateApp(err)
    })
    
    // Event listener here in case connection is closed for some reason
    gConnection.on('close', () => {
      terminateApp(err)
    })
  }
  catch (err) {
    terminateApp(err)
  }
}

// Try to create a connection using the appropriate credentials in the conStr
// If successful, create a channel which can support multiple queues
// Otherwise throw an error which will terminate the app
async function createConnection(conStr) {
  try {
    const connection = await amqp.connect(conStr) // Create tcp connection   // Create connection
    console.log(`Connected to rabbitmq using ${conStr}`)

    const channel = await connection.createChannel() // create a channel withing the connection. Can have many concurrent channels   // Create channel. Channel can have multiple queues
    console.log(`Channel created`)

    return { connection, channel } 

  } catch (err) {
    console.log(`Failed to connect to queue in createConection function`)
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

// createMessage() creates a random message to add to the queue
// The message is converted to a binary array and sent to the queue
// The 'category' queue is used or created if it doesn't exist
// Send numMessages random messages to the queue
async function sendRandMsg(channel, category, numMsgs) {
  for (i = 0; i < numMsgs; i++) {
    try {
      const res = await channel.assertQueue(category, { durable: true })  // Create queue called whatever is in category if one doesn't exist
      console.log(`${category} queue created`)
      const msg = createMessage()  // Create the random message and return it
      const buffer = Buffer.from(JSON.stringify(msg)) // Convert javascript object to json then add to mutable buffer in binary
      console.log('Buffer contents are: ', buffer.toString('hex'))
      await channel.sendToQueue(category, buffer, { persistent: true }) //  Send data stream to the queue. Saves to volume to survive broker restart
      console.log(msg)
    } catch (err) {
      console.log(`Failed to write to ${category} queue. ${err}`)
      throw err
    }
  }
}


// This function writes one json message to the queue based on the msg.category property
// i.e. the queue created is specified in msg.category
async function sendMsg(channel, msg) {
  try {
    const res = await channel.assertQueue(msg.category, { durable: true })    // Create queue called whatever is in category if one doesn't exist
    console.log(`${msg.category} queue created / accessed`)
    await channel.sendToQueue(msg.category, Buffer.from(JSON.stringify(msg)), { persistent: true }) // Saves to volume to survive broker restart
    console.log(msg)
  } catch (err) {
    console.log(`Failed to write to ${category} queue.${err}`)
  }
}


// Create a realistic looking message of the specified  based on random selections from arrays of text
function createMessage() {
  const compManufacturer = ['Dell', 'HP', 'Acer', 'Asus', 'Samsung', 'Toshiba']
  const compDevice = ['Laptop', 'desktop', 'Monitor', 'Keyboard']

  const msg = {}
  msg.make = compManufacturer[getRand(0, compManufacturer.length - 1)]
  msg.device = compDevice[getRand(0, compDevice.length - 1)]
  msg.cost = getRand(10, 3000)
  return msg
}

// Get a random number between lower and upper inclusive
function getRand(lower, upper) {
  lower = Math.ceil(lower)
  upper = Math.floor(upper)
  return Math.floor(Math.random() * (upper - lower + 1)) + lower
}


// Something has gone wrong so kill the app and let docker have another go at restarting it
function terminateApp(error) {
  console.log('Unexpected error: ', error.message ? error.message : error.stack) // Inconsistent error reporting. Not all have .message

  if (gConnection) {
    closeConnection(gConnection, gChannel)
    console.log(`Closing connections`)
  }
  
  console.log(`Shutting down node server listening on port ${APP_PRODUCER_PORT}`)
  server.close() // Close the http server created with app.listen.
  console.log(`Closing app with process.exit(1)`)
  process.exit(1)  // Exit process with an error to force the container to stop
}

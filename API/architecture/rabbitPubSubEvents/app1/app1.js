const express = require('express');
const amqp = require('amqplib');
const fs = require('fs').promises;
const path = require('path');

const APP1_PORT = process.env.APP1_PORT || 3001;
const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://admin:admin@localhost:5672';
const DATA_FILE = process.env.COMPONENTS_FILE || './app1/data/components.json';

const app = express();
app.use(express.static(path.join(__dirname, 'public')));

// AMQP vars
const EXCHANGE = 'new_component';  // Publisher: fanout exchange for app1 -> app2 & app3. No topic needed as no filtering used
const SUBMITTED_COMPONENT_QUEUE = 'submitted_component'; // Single queue to hold whatever App2 posted

let channel = null; // Channel supports multiple connections so only need one for pub and consume

async function ensureDataFile() {
  try {
    await fs.access(DATA_FILE);
  } catch {
    await fs.mkdir(path.dirname(DATA_FILE), { recursive: true });
    await fs.writeFile(DATA_FILE, JSON.stringify([]));
  }
}

async function appendToFile(component) {
  const text = await fs.readFile(DATA_FILE, 'utf8');
  const arr = JSON.parse(text || '[]'); // If the file is empty, add []
  arr.push(component);
  await fs.writeFile(DATA_FILE, JSON.stringify(arr, null, 2)); // Write formatted
  console.log(`App3 says: "${component}" added to the file cache`);
  console.log('App3 file cache contents are:', arr);
}

// Try to connect to broker. If that fails, throw an exception in the while loop and try it all again after 2 seconds
// Register callbacks to respond to connection errors later. For an error, just report it. For loss of connection. try to reestablish every 2 seconds
// This could happen if the broker isn't ready as we can't use a health check as we are not in the same Docker network or broker goes down then back up
// Create the channel and on that channel create the exchange to publish to multiple subscribers and a queue to consume from a single producer
// We can't use a health check on the broker container as they are not in the same docker network in this example as they will end up in different VMs
async function connect() {
  while (!channel) {
    try {
      console.log('App1 says: connecting to', RABBITMQ_URL);
      const conn = await amqp.connect(RABBITMQ_URL);
      conn.on('error', () => console.log('App1 says: broker connection error'));
      conn.on('close', () => {
        console.log('App1 says: connection closed, will retry');
        channel = null; // Clear the old channel and try to create a new one in 2 seconds
        setTimeout(connect, 2000);
      });

      channel = await conn.createChannel();
      await channel.assertExchange(EXCHANGE, 'fanout', { durable: false }); // Create the exchange as the publisher. Subscribers will create the queues
      await channel.assertQueue(SUBMITTED_COMPONENT_QUEUE, { durable: false }); // Create the queue to consume from the APP2_QUEUE. Create if not there

      // Register the callback to consume messages from app2. This callback will be called by app2 for every message in the queue
      await channel.consume(SUBMITTED_COMPONENT_QUEUE, async msg => {
        if (!msg) return;
        try {
          const obj = JSON.parse(msg.content.toString()); // Deserialise into a JSON object
          const component = String(obj.component);
          console.log(`App1 says: got component submission "${component}" from app2`);
          handleIncomingComponent(component); // If not in the list (database) add it
        } catch (err) {
          console.log('App1 says: bad message received from app2');
        } finally {
          channel.ack(msg); // Delete the message from the queue
        }
      });

      console.log(`App1 says: Consumer callback registered and connected. Will consume from "${SUBMITTED_COMPONENT_QUEUE}" queue`);
    } catch (err) {
      console.log('App1 says: connection failed, retrying in 2s');

      // Wait 2 seconds. Promise is created and resolve function passed to setTimeout to be called after 2 seconds
      // The promise resolves as it can't do anything else. Await will prevent further execution of the async connect function
      // until the promise is resolved. i.e. its a delay within an async function
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
}

// A new item has been added to the master data store so update all interested systems of this event by
// publishing to all subscriber queues mapped to this exchange
function publishNewComponent(event) {
  if (!channel) {
    console.log('App1 says: not connected to broker, cannot publish anything');
    return;
  }
  const msg = Buffer.from(JSON.stringify({ component: event })); // Serialise the event into a buffer called msg then publish it
  channel.publish(EXCHANGE, '', msg);
  console.log(`App1 says: published master data store insert event "${event}" to all subscribers`);
}

// Takes a received message. As the user could have entered it in a free text box, remove space either end as we need to compare it
// to the content of the array (database). You may wish to make all lower or uppercase but that's not important here
// If it exists then say so and if not, insert it into the database (array)
async function handleIncomingComponent(comp) {
  const components = await fs.readFile(DATA_FILE, 'utf8'); // Access database - this is different for mysql
  const component = String(comp).trim(); // We are going to make a comparison of something typed in app2 so trim it for spaces
  if (components.includes(component)) {
    console.log(`App1 says: ${component} already exists in the master data store so not inserting`);
  } else {
    await appendToFile(component); // Insert into database
    console.log(`App1 says: ${component} added to the master data store`);
    console.log('App1 says: current components in master data store are:', components);
    publishNewComponent(component); // notify subscribers of the new component by pushing to their queues
  }
}

// GET /components -> returns file contents - i.e. a copy of all the components in the master data store
app.get('/components', async (req, res) => {
  try {
    const text = await fs.readFile(DATA_FILE, 'utf8');
    res.json(JSON.parse(text || '[]'));
  } catch {
    res.status(404).json([]);
  }
});

// Kill the app to emulate failure
app.get('/killme', (req, res) => process.exit(0));


// Start http server and connect to broker
app.listen(APP1_PORT, async () => {
  console.log('App1 listening on', APP1_PORT);
  await ensureDataFile();
  connect(); // start AMQP connect loop
});
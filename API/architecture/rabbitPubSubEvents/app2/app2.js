const express = require('express');
const bodyParser = require('body-parser');
const amqp = require('amqplib');
const fs = require('fs').promises;
const path = require('path');
const app = express();
const APP2_PORT = process.env.APP2_PORT || 3002;
const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://admin:admin@localhost:5672';
const DATA_FILE = process.env.COMPONENTS_FILE || './app2/data/components.json';


app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

const EXCHANGE = 'new_component'; // New components added to the master data store will be published through this exchange
const EVENT_CONSUMER_QUEUE = 'app2_new_component_event'; // Consume master data updates from here
const SUBMITTED_COMPONENT_QUEUE = 'submitted_component'; // Single queue to hold whatever App2 posted

let channel = null;

// Keep a synchronised cached version of the master data. If the file doesn't exist then create it
async function ensureDataFile() {
  try {
    await fs.access(DATA_FILE); // Is it there? If not, access throws an exception
  } catch {
    await fs.mkdir(path.dirname(DATA_FILE), { recursive: true });
    await fs.writeFile(DATA_FILE, JSON.stringify([]));
  }
}

// Append the new component added to the master data store to the local file cache
// It's not as simple as just using fs.appendFile as we want to maintain the json structure
// so create an array, read the file into it, push the object into the array then write the array
// If this was a big file, this wouldn't be a performant solution but it only holds dropdown list items
async function appendToFile(component) {
  const text = await fs.readFile(DATA_FILE, 'utf8');
  const arr = JSON.parse(text || '[]'); // If the file is empty, add []
  arr.push(component);
  await fs.writeFile(DATA_FILE, JSON.stringify(arr, null, 2)); // Write formatted
  console.log(`App2 says: "${component}" added to the file cache`);
  console.log('App2 file cache contents are:', arr);
}

// Basically the same as App1 comment block. Differences are commented in the code below
async function connect() {
  while (!channel) {
    try {
      console.log('App2 says: connecting to', RABBITMQ_URL);
      const conn = await amqp.connect(RABBITMQ_URL);
      conn.on('error', () => console.log('App1 says: broker connection error'));
      conn.on('close', () => {
        console.log('App2 says: connection closed, will retry');
        channel = null; // Clear the old channel and try to create a new one in 2 seconds
        setTimeout(connect, 2000);
      });

      channel = await conn.createChannel();
      const q = await channel.assertQueue(EVENT_CONSUMER_QUEUE, { durable: false }); // Create the q if it doesn't exist
      await channel.bindQueue(q.queue, EXCHANGE, ''); // bind the q to the exchange for subscription
      await channel.prefetch(1); // Only send the next message when the current is acknowledged

      // Register the callback. Wait until registration is confirmed by resolving the promise
      // The broker will push the message on the queue from the broker through TCP socket (channel). AMQP receives it an invokes this callback
      await channel.consume(q.queue, async msg => {
        if (!msg) return;
        const obj = JSON.parse(msg.content.toString()); // Deserialise the message and append to the file
        console.log(`App2 says: new component event "${obj.component}" received`)
        await appendToFile(String(obj.component).trim());
        channel.ack(msg); // Acknowledge the message to delete from the queue so another can be sent if available
      });
      console.log(`App2 says: connected and consuming from ${EVENT_CONSUMER_QUEUE} queue`);
    } catch (err) {
      console.log('App2 says: connection to broker failed, retrying in 2 seconds');
      await new Promise(resolve => setTimeout(resolve, 2000)); // Wait 2
    }
  }
}

// POST /component -> publish to app1 queue
// Submitted component is retrieved from the body
app.post('/component', async (req, res) => {
  const component = (req.body && req.body.component) || '';
  if (!component || !component.trim()) return res.status(400).json({ error: 'component required' });
  if (!channel) return res.status(500).json({ error: 'not connected to broker yet' });
  const payload = Buffer.from(JSON.stringify({ component: component.trim() })); // Serialise
  await channel.assertQueue(SUBMITTED_COMPONENT_QUEUE, { durable: false }); // Create if not exist
  channel.sendToQueue(SUBMITTED_COMPONENT_QUEUE, payload);
  console.log(`App2 says: user submitted component "${component}". Sent to "${SUBMITTED_COMPONENT_QUEUE} queue`);
  res.sendStatus(200);
});


// GET /components -> returns file contents - i.e. a copy of all the components in the master data store
app.get('/components', async (req, res) => {
  try {
    const text = await fs.readFile(DATA_FILE, 'utf8');
    res.json(JSON.parse(text || '[]'));
  } catch {
    res.status(404).json([]);
  }
});


app.listen(APP2_PORT, async () => {
  console.log('App2 says: listening on', APP2_PORT);
  await ensureDataFile(); // Create cache file if it doesn't exist
  connect(); // Connect to the message broker and set up callback listener
});
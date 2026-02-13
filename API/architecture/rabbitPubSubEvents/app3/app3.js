const express = require('express');
const amqp = require('amqplib');
const fs = require('fs').promises;
const path = require('path');
const app = express();
const APP3_PORT = process.env.APP3_PORT || 3003;
const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://admin:admin@localhost:5672';
const DATA_FILE = process.env.COMPONENTS_FILE || './app3/data/components.json';

app.use(express.static(path.join(__dirname, 'public')));

const EXCHANGE = 'new_component';
const EVENT_CONSUMER_QUEUE = 'app3_new_component_event'; // Consume master data updates from here for app3. 

let channel = null;

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

// Basically the same as App1 comment block. Differences are commented in the code below
async function connect() {
  while (!channel) {
    try {
      console.log('App3 says: connecting to', RABBITMQ_URL);
      const conn = await amqp.connect(RABBITMQ_URL);
      conn.on('error', () => console.log('App3 says: broker connection error'));
      conn.on('close', () => {
        console.log('App3 says: connection closed, will retry');
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
        console.log(`App3 says: new component event "${obj.component}" received`)
        await appendToFile(String(obj.component).trim());
        channel.ack(msg); // Acknowledge the message to delete from the queue so another can be sent if available
      });
      console.log(`App3 says: connected and consuming from ${EVENT_CONSUMER_QUEUE} queue`);
    } catch (err) {
      console.log('App3 says: connection to broker failed, retrying in 2 seconds');
      await new Promise(resolve => setTimeout(resolve, 2000)); // Wait 2
    }
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


app.listen(APP3_PORT, async () => {
  console.log('App3 listening on', APP3_PORT);
  await ensureDataFile();
  connect();
});
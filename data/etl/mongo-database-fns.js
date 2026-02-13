const mongoose = require('mongoose')
const extractData = require('./extractData')

const DB_NAME = process.env.DATABASE      || 'triv'
const MONGO_HOST = process.env.HOST_NAME  || 'localhost' // Local host just for testing. Use service name when etl is in a container
const MONGO_PORT = process.env.MONGO_PORT || 27017

const trivSchema = new mongoose.Schema({
 question: {
  type: String,
  required: true
 },
 answer: {
  type: String,
  required: true
 }
})

const conStr = `mongodb://${MONGO_HOST}:${MONGO_PORT}/${DB_NAME}`

async function connectToMongoDB() {
 try {
  // Connect to MongoDB using Mongoose
  await mongoose.connect(conStr)
  const dbName = mongoose.connection.name
  return dbName
 } catch (err) {
  throw err // Throw to caller
 }
}

async function getData(collectionName) {
 // model - creates a javascript object we work with and Mongoose checks against the schema and reads / writes the collection mapping to document atttributes
 //const trivModel = mongoose.model('question', trivSchema) // Expects to find a collection called questions - i.e. plural
 const collection = mongoose.model(`${collectionName}`, trivSchema)
 try {
  const questions = await collection.find() // Get all of them
  if (questions.length == 0) throw ('Not found')
  else
   return questions
 } catch (err) {
  throw (err)
 }
}


async function dropTable(collectionName) {
 try {
  const collection = mongoose.model(`${collectionName}`, trivSchema)
  let result = await collection.collection.drop()
  return false // as in no error
 } catch (err) {
  throw (err)
 }
}

// This is a function stub just to avoid changing the calling program
// It does nothing as there is no need to explicitly create a collection as one is
// created when data is saved to it if it doesn't exist
async function createTable(tableName) {
 return true
}

// Note: this function looks for tabs between Q and A and CR for end of question
// so last question in the data file must end with a CR 
async function etl(tableName, filename) {
 const [qArr,ansArr] = await extractData(filename)

 //  Create an array of objects to make up the mongo document then load into database
 let docArray = [] // Add all the q and a objects to the array
 let i = 0
 while (i < qArr.length) {
  let doc = {}
  doc.question = qArr[i]
  doc.answer = ansArr[i]
  docArray.push(doc)
  i++
 }

 try {
  const collection = mongoose.model(`${tableName}`, trivSchema)
  await collection.insertMany(docArray) // Insert the whole array
  return false // as in no error
 } catch (err) {
  throw (err)
 }
}



// Count the documents in the collection
async function countRows(collectionName) {
 try {
  const collection = mongoose.model(`${collectionName}`, trivSchema)
  return await collection.countDocuments() // Return the count
 } catch (err) {
  throw (err)
 }
}

// Connect and return database name
async function isConnected() {
 const dbname = await connectToMongoDB()
 return dbname
}


module.exports = {
 getData,
 countRows,
 createTable,
 etl,
 dropTable,
 isConnected
}
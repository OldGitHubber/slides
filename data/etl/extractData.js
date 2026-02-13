// Function reads tab delimited data from a file. Question then tab then answer then new line
// Don't leave blank line at end of file. Clean the data first - remove any non-standard chars
// Assumes that as on Windows, it will use Windows end of line \r\n
const fs = require('fs').promises

async function extractData(filename) {
 let data = await fs.readFile(filename, "binary") // Uses built-in promise
 data = data.replace(/'/g, "\\'") // Escape all apostrophes
 let question = ''
 let answer = ''
 let isQuestion = true // Determine if reading a q or a
 let qArr = []         // Build up the extracted questions
 let ansArr = []       // Build up the extracted answers
 const TAB = '\t'  // Tab char delimiter for question
 const CR = '\r'   // Carriage return delimiter for answer
 const LF = '\n'   // Line Feed
 
 
 // Extract all questions and answers into arrays. These are tab and eol delimited
 for (let i = 0; i < data.length; i++) {
  if (isQuestion) {
   if (data[i] != TAB) {
    question += data[i]
   } else {
    isQuestion = false
    qArr.push(question)
    question = ''
   }
  } else {
   if (data[i] != CR && data[i] != LF) {
    answer += data[i]
   } else {
    // No need to jump CR as loop will do that
    if (data[i + 1] == LF) i++ // But if next is LF, i.e. Windows, need to force a jump
    isQuestion = true
    ansArr.push(answer)
    answer = ''
   }
  }
 }
  console.log(qArr)
 return [qArr, ansArr]

}

module.exports =  extractData  // Load data from file and transform into a form for database
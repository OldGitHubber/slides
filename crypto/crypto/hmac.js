// Hash-based message authentication code
// sha256 HMAC of the file is:
// a8250a5443de24fe51c64c7b9a7829b729c20fbf762975ce18ff92478de21fd9
// Changing 1 bit, h to i, the hmac is:
// c22e6fab817745dc5c2f6f7da96c73ebda99f21d2ac9d1142d0b17d95debf591

const crypto = require('crypto')
const fs = require('fs')

const sourceFile = 'quiz.txt'
const secretKey = 'umpalumpa123!!'

const algorithm = 'sha256'
const encoding = 'hex'

let data = ''

try {
 data = fs.readFileSync(sourceFile, 'utf8')
} catch (err) {
 console.log('Error:', err)
}


const dataHmac = hmac(algorithm, encoding, data, secretKey)
console.log(`The data from ${sourceFile} has a hmac of:\n${dataHmac}\nusing the ${algorithm} algorithm`)

// The receipient would take the file and hmac with the same shared secret to validate the message


// ******** Functions ************

function hmac(algorithm, encoding, data, secret) {
 const hmacObj = crypto.createHmac(algorithm, secret)
 hmacObj.update(data)
 return hmacObj.digest(encoding)
}
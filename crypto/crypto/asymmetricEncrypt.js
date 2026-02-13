// Alice encrypts a message for bob
const fs = require('fs')
const crypto = require('crypto')
const bobPublicKeyFilename = 'bobPub.pem'
const ciphertextFilename = 'cypherText.txt'

const publicKey = fs.readFileSync(bobPublicKeyFilename, 'utf-8')            // Load public key from file
const plainText = 'Bob, the date is set for Wednesday the 5th - from Alice'  // Data to be encrypted - could be a file

const cypherText = crypto.publicEncrypt(publicKey, Buffer.from(plainText, 'utf-8')) // Encrypt data with public key

console.log(`The message "${plainText}" is encrypted to:
${cypherText.toString('hex')}
 
or in base 64:
${cypherText.toString('base64')}

Writing cypherText to file: ${ciphertextFilename}`)

fs.writeFileSync(ciphertextFilename, cypherText.toString('base64'))



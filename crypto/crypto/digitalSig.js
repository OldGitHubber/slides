// Alice sends a message to Bob and a digital signature
const crypto = require('crypto')
const fs = require('fs')
const privateKeyFilename = 'alicePriv.pem'
const msgFilename = 'bobMsg.txt'
const msgSignatureFilename = 'aliceSignature.txt'
const fileToBeSigned = 'quiz.txt'

const data = fs.readFileSync(fileToBeSigned, 'utf-8')
const privateKey = fs.readFileSync(privateKeyFilename, 'utf-8') // Load private key from file

const signObj = crypto.createSign('SHA256') // Create a Signing object using standard secure hashing algorithm
signObj.update(data)                        // Add data to signing object

const signature = signObj.sign(privateKey, 'base64') // Sign the data using the private key

fs.writeFileSync(msgSignatureFilename, signature) // Base 64 signature to send

console.log(`Alice's message to Bob is in: "${fileToBeSigned}"

which has a digital signature:
${signature}

Signature written to ${msgSignatureFilename}`)


// Bob checks Alice's signature on the message she sent
const crypto = require('crypto')
const fs = require('fs')
const publicKeyFilename = 'alicePub.pem'
const msgFilename = 'quiz.txt'
const msgSigFilename = 'aliceSignature.txt'


const publicKey = fs.readFileSync(publicKeyFilename, 'utf-8') // Load Alice's public key from file
const data = fs.readFileSync(msgFilename, 'utf-8')             // Load message from Alice
const sig = fs.readFileSync(msgSigFilename, 'utf-8')          // Load signature from Alice for bob to check

const verifyObj = crypto.createVerify('SHA256') // Create a Verify object using same algorithm as Alice's
verifyObj.update(data) // Update the Verify object with data to be verified

const isSignatureValid = verifyObj.verify(publicKey, sig, 'base64') // Verify Alice's signature using her public key

console.log(`The file has ${isSignatureValid ? 'a valid' : 'an invalid'} Digital Signature.`)

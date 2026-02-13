const crypto = require('crypto')
const fs = require('fs')

const bobPrivateKeyFilename = 'bobPriv.pem'
const plainTextFile = 'plaintext.txt'
const cypherTextFile = 'cypherText.txt'

const privateKey = fs.readFileSync(bobPrivateKeyFilename, 'utf-8') // Load private key from file

if (fs.existsSync(cypherTextFile)) {
 const cypherText = fs.readFileSync(cypherTextFile, 'utf8')  // load the encrypted file

 const plainText = crypto.privateDecrypt({ key: privateKey }, Buffer.from(cypherText, 'base64'))

 console.log(`Writing cypherText to file: ${plainTextFile}`)
 fs.writeFileSync(plainTextFile, plainText)
} else {
 console.log(`${cypherTextFile} does not exist`)
}
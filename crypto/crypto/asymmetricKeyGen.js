const fs = require('fs')           // File system lib
const crypto = require('crypto')
const alicePublicKeyFilename = 'alicePub.pem'
const alicePrivateKeyFilename = 'alicePriv.pem'
const bobPublicKeyFilename = 'bobPub.pem'
const bobPrivateKeyFilename = 'bobPriv.pem'

// Generate key pair
// crypto.generateKeyPairSync(type, options) where type is: 'rsa', 'dsa' (digital signature algorithm), 'ec' (eliptical curve)
// Options is an object and depend on key type. For rsa:
const keyOptions = {
  modulusLength: 2048,   // Number of bits in the key modulus. Typically 2048 or 4096
  publicKeyEncoding: {
    type: 'spki',        // encoding option. Typically SubjectPublicKeyInfo (spki)
    format: 'pem'        // Output format. Typically Privacy Enhanced Mail (PEM). Has headers -----BEGIN PRIVATE KEY----- etc. Data is in base64 for email etc
  },
  privateKeyEncoding: {
    type: 'pkcs8',       // Encoding Private Key Cryptography Standards #8 (pkcs8)
    format: 'pem'        // As above
  }
}

try {
  // function returns two attributes: publicKey and Private key so deconstruct them (or use the object and reference these attributes)
  const { publicKey:alicePublicKey, privateKey:alicePrivateKey } = crypto.generateKeyPairSync('rsa', keyOptions)
  fs.writeFileSync(alicePublicKeyFilename, alicePublicKey)  // This is sent to Bob and anyone else
  fs.writeFileSync(alicePrivateKeyFilename, alicePrivateKey)

  const { publicKey:bobPublicKey, privateKey:bobPrivateKey } = crypto.generateKeyPairSync('rsa', keyOptions)
  fs.writeFileSync(bobPublicKeyFilename, bobPublicKey)  // This is sent to Bob and anyone else
  fs.writeFileSync(bobPrivateKeyFilename, bobPrivateKey)

  console.log(`Key pairs generated saved to: "${alicePublicKeyFilename}" and "${alicePrivateKeyFilename}", "${bobPublicKeyFilename}" and "${bobPrivateKeyFilename}".`)
} catch (err) {
  console.log('Key gen failed:', err)
}
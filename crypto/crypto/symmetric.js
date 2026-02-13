const crypto = require('crypto')

const msg = 'Please symmetrically encrypt me.'
const algorithm = 'AES-256-GCM' // AES-128-CBC, AES-192-CBC, AES-256-CBC, AES-128-GCM, AES-192-GCM, AES-256-GCM, DES, 3DES (Triple DES), Blowfish, RC4
const encoding = 'hex'

// Generate a random key of the correct length for encryption using AES-xxx-GCM - Galois/Counter Mode is a popular alg as it also provides an authentication tag
const secretKey = crypto.randomBytes(32).toString('hex')
const cypherTextObj = gcmEncrypt(algorithm, encoding, msg, secretKey) // cypherTextObj is an object with the crypto string, IV and auth tag
console.log(`Secret key is:`, secretKey)
console.log(`The string: "${msg}" has been encrypted and created:
Cypertext: ${cypherTextObj.cypherText} 
Initialisation Vector: ${cypherTextObj.iv}
Authentication Tag: ${cypherTextObj.authenticationTag}\n`)


// Try to decrypt the message
try {
  console.log(`Attempting to decrypt the cyphertext: ${cypherTextObj.cypherText}`)
  const plainText = gcmDecryptText(cypherTextObj, secretKey, algorithm)  // Secret key is the symmetric key used to encrypt
  console.log(`Decrypted message is: "${plainText}"`)
} catch (err) {
  console.log(`Failed to decrypt the message. Error returned is: `, err.message)
}



// ********* Functions *******************

function gcmEncrypt(algorithm, encoding, data, key) {
  // Generate a random IV (Initialization Vector). 12 bytes is recommended even though others will work
  // This is used to ensure that each message is encrypted differently to avoid a pattern forming if the
  // same message is sent several times where the cypherText would have the same values thus helping a hacker
  const iv = crypto.randomBytes(12) 

  // createCipheriv takes an algorithm, a key of specific length and an initialisation vector (random string)
  // and creates a cipher object which can be used to encrypt data
  const cipherObj = crypto.createCipheriv(algorithm, Buffer.from(key, encoding), iv)

  // Update the cipherObj with the plaintext. Update adds a block of data and may be called several 
  // times in block based ciphers to process a block at a time and cipher blocks are concatenated. 
  // final is called at the end to finalise the last block to produce the encrypted data
  const encryptedText = Buffer.concat([cipherObj.update(data, 'utf8'), cipherObj.final()])

  // Get the authentication tag - effectively same concept as hmac to provide integrity and authentication check
  const authenticationTag = cipherObj.getAuthTag()

  // Return the IV, encrypted text, and authentication tag
  return {
    iv: iv.toString(encoding),
    cypherText: encryptedText.toString(encoding),
    authenticationTag: authenticationTag.toString(encoding),
  }
}

function gcmDecryptText(encryptedData, key, algorithm) {
  const { iv, cypherText } = encryptedData // Decompose the cypherTextObj into its component parts
  let authenticationTag = encryptedData.authenticationTag // Make this variabe so we can corrupt it. Would normally be const with the other two
  //authenticationTag = authenticationTag.substring(0, 0) + '7' + authenticationTag.substring(5) // Overwrite the first char of the tag and hope it wasn't a 7

  const decipherObj = crypto.createDecipheriv(algorithm, Buffer.from(key, encoding), Buffer.from(iv, encoding)) // Decipher obj initialised with alg, key and iv

  decipherObj.setAuthTag(Buffer.from(authenticationTag, encoding))

  try {
    const plainText = Buffer.concat([decipherObj.update(Buffer.from(cypherText, 'hex')), decipherObj.final()]).toString('utf8') // Update data block and finalise last block and convert to text
    return plainText
  } catch (err) {
    throw err
  }

}





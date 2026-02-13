const crypto = require('crypto')

// Alice and Bob agree on a standardized group (e.g., MODP Group 14) is common where Prime (p) is 2048-bit prime number and generator (g) is 2.
// Or generate a new one and send it to Alice as below
// const prime = crypto.createDiffieHellman(2048).getPrime()
// const generator = 2; // A commonly used generator

// Or use the common MODP group 14 precomputed values - which is quicker

const g14Prime = 'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF6955817183995497CEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF'
const g14Gen = '02'

// Convert these strings into binary bits in buffers (arrays)
const p = Buffer.from(g14Prime, 'hex')
const g = Buffer.from(g14Gen, 'hex')



// Alice's side
const alice = crypto.createDiffieHellman(p, g)
const alicePublicKey = alice.generateKeys()

// Out-of-band: Alice sends her public key to Bob or they both use the MODP Group 14 as in this case

// Bob's side
const bob = crypto.createDiffieHellman(p, g)
const bobPublicKey = bob.generateKeys()

// Out-of-band: Bob sends his public key to Alice. They may well be converted to base64, transferred then converted back

const aliceSecret = alice.computeSecret(bobPublicKey)
const bobSecret = bob.computeSecret(alicePublicKey)



// Output in hex for comparison
console.log(`Alice's secret key:
${aliceSecret.toString('hex')}\n`)

console.log(`Bob's secret key:
${bobSecret.toString('hex')}`)
// Both Alice and Bob now share a secret derived from the key exchange

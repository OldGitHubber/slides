// Changing one bit makes a big difference. h = 0x68 or 01101000 and i = 0x69 or 01101001 so only one bit changes
// Changing What to Wiat in the file is a single bit change
// 9ddd6ee5f9178e46ffc2d5f7582b21af857e0799e480d770141af35da32c53a258a86f7f09becf566d5c73a4eb2f1febc90dd2b0f4ae429f60d4ee4d655cb4d0
// becomes
// 1b58666d1c046dfd77dc990dc5f666750981ab54e98958c0cb3b7b5320c6aa707516a21ce92511376ca8451dec1c7743d62fd917b988db476e50cba774537ff7


const crypto = require('crypto')
const fs = require('fs')
const sourceFile = 'quiz.txt'
let data = ''

try {
    data = fs.readFileSync(sourceFile, 'utf8')
} catch (err) {
    console.log('Error:', err)
}

const algorithm = 'sha512'    // available: sha1, sha256, sha512, sha384, md5
const encoding = 'hex'        // available: hex (default), base64, binary, latin1 (western european)

const hashedData = hash(algorithm, encoding, data)
console.log(`The data: \n${data} \nis hashed to:\n${hashedData} \nusing ${algorithm}`)

// ******* functions ***********
function hash(algorithm, encoding, data) {
    const hashObj = crypto.createHash(algorithm) // Initialise the hash object with the specific algorithm
    hashObj.update(data)                         // Add data to the hash. Can call this several times if there are blocks of data
    return hashObj.digest(encoding)              // Finalise the hash based on all the data provided in update & returns formatted result
}


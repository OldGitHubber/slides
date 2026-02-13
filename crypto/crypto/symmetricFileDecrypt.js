const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

const secretKey = 'b57660888caee7c21849dc98198d60dbf5a66f211f45f10eb618d1c271e608d3'; // AES256 so 64 chars
const key = Buffer.from(secretKey, 'hex');

const encryptedPath = path.join(__dirname, 'privateStuff.enc');

// Read encrypted data
const encryptedData = fs.readFileSync(encryptedPath) ;

// Extract IV, AuthTag, and Ciphertext
const iv = encryptedData.slice(0, 12);
const authTag = encryptedData.slice(12, 28);
const ciphertext = encryptedData.slice(28);

// Decrypt
try {
const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
decipher.setAuthTag(authTag);

const decrypted = Buffer.concat([decipher.update(ciphertext), decipher.final()]);
console.log('Decrypted content:\n', decrypted.toString('utf8'));
} catch (err) {
  console.log('Failed to decrypt the data')
}

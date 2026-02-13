const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

const secretKey = 'b57660888caee7c21849dc98198d60dbf5a66f211f45f10eb618d1c271e608d3'; // 64 char as AES256 key
const key = Buffer.from(secretKey, 'hex');
const iv = crypto.randomBytes(12);  // Recommended IV size for GCM

const inputPath = path.join(__dirname, 'privateStuff.txt');
const outputPath = path.join(__dirname, 'privateStuff.enc');

// Read file content
const plaintext = fs.readFileSync(inputPath);

// Encrypt
const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
const encrypted = Buffer.concat([cipher.update(plaintext), cipher.final()]);
const authTag = cipher.getAuthTag();

// Combine IV + AuthTag + Ciphertext
const combined = Buffer.concat([iv, authTag, encrypted]);

// Write to encrypted file
fs.writeFileSync(outputPath, combined);

console.log(`File encrypted and written to ${outputPath}.`);
console.log(`Secret key is: ${secretKey}`)
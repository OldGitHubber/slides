
// This module aims to avoid the problem of keep forgetting to update the API endpoint in the client javascript
// when changing from the host machine, to docker, to cloud
// Put {{API_HOST}} in the javascript client fetch and save the file something like base.js or template.js or whatever
// Call this function with the base code as sourceFile and the actual javascript file name as referenced in the html
// as the dest file. Make the call at the start of the node app server code so it is executed when the file is first
// executed. This function will copy the base file, name it as the required javascript file having substituted 
// the {{API_HOST}} with IP:port passed in from the app which is dependant on the execution environment
const fs = require('fs/promises')

async function updateHostAddress(host, sourceFile, destFile) {
  try {
    let data = await fs.readFile(sourceFile, 'utf-8')  // Read the reference file with the {{ }} in it
    await fs.writeFile(destFile, data, 'utf-8')        // Copy to create the javascipt file to modify
    data = data.replace(/{{API_HOST}}/g, host)         // Find the {{}} and replace it with IP:port
    await fs.writeFile(destFile, data)                 // Write the modified file to be server up
    console.log(`${sourceFile} copied to ${destFile}`)
    console.log(`Set API endpoint host to: ${host}`)

  } catch (err) {
    console.error(`File copy failed: ${err.message}`)
  }
}

exports.updateHostAddress = updateHostAddress
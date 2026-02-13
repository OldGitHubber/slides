# FROM defines the base layer of the image. This image base is node and alpine linux
FROM node:slim

# WORKDIR defines the directory in the container that following commands reference
WORKDIR /usr/app

COPY package*.json .


# COPY . means all files in the current directory into the same directory structure in the Docker image - under app in this case
COPY . .

# run shell command. all_http_methods_demonpm will be run from efectively within the image to deploy dependencies in the package.json into the image
RUN npm install


# npm start is the command to start the app.js file as start is defined in the packages.json file as "start": "node app.js"
# so node will run and app.js is the entry point which will start the server listeing on the specified port
CMD ["node", "app.js"]
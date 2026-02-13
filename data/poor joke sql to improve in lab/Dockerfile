# FROM defines the base layer of the image. This image base is node and alpine linux
# This can be a path / url to download a base image
FROM node:alpine

# WORKDIR defines the directory in the container that following commands reference
WORKDIR /usr/app

# copy any package files into WORKDIR
COPY package*.json .

# run shell command. all_http_methods_demonpm will be run from effectively within the image to deploy dependencies in the package.json into the image
RUN npm install

# COPY . all files in the current directory into the same directory structure in the Docker image - under app in this case except .dockerignore files
COPY . .

# npm start is the command to start the app.js file as start is defined in the packages.json file as "start": "node app.js"
# so node will run and app.js is the entry point which will start the server listening on the specified port
CMD ["node", "app.js"]



FROM node:alpine
WORKDIR /usr/app
COPY package*.json .
RUN npm install
COPY . .
CMD ["node", "app.js"]
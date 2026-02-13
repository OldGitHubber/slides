FROM node:alpine
WORKDIR /usr/app
COPY ./package*.json .
RUN npm install
COPY ./app.js .
COPY ./.env .
COPY ./tnLib.js .
COPY ./public/ ./public/
COPY ./jokes.json .

# npm start is the command to start the app.js file as start is defined in the packages.json file as "start": "node app.js"
# so node will run and app.js is the entry point which will start the server listeing on the specified port
CMD ["npm", "start"]
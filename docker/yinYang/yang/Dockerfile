FROM node:alpine
WORKDIR /usr/src/app
COPY ./package*.json .
RUN npm install
COPY . .
#EXPOSE 3001  only used for documentation. Desktop will need it if you use that
CMD ["npm", "start"] 
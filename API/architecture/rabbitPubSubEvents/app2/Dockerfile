FROM node:alpine
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
CMD ["node", "app2.js"]
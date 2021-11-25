FROM node:8

WORKDIR /code

COPY package*.json .
RUN npm ci --only=production

COPY . .

EXPOSE 8080
CMD [ "npm", "start" ]
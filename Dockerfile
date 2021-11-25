# syntax=docker/dockerfile:1

#Define Base Image (OS)
FROM node:8

#Define/Create Work Directory
WORKDIR /code

#Copy Package.json to Work Directory and run npm
COPY package*.json ./
RUN npm ci --only=production

# copy the content of the local directory to the working directory
COPY . .

#Expose Port 80 and define the entry point command
EXPOSE 8080
CMD [ "npm", "start" ]
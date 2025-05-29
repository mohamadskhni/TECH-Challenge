# Use official Node.js LTS image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json if available
COPY package*.json ./

# Install dependencies
RUN npm install express

# Copy app source code
COPY app.js .

# Expose port
EXPOSE 3001

# Start the app
CMD ["node", "app.js"]

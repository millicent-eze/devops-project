# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first (better Docker caching)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy app code
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the app
CMD ["node", "server.js"]

# Use official lightweight Node.js image
FROM node:20-alpine

# Create app directory
WORKDIR /app

# Copy dependency files first (better caching)
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy application source
COPY src ./src

# Expose application port
EXPOSE 8080

# Start the application
CMD ["node", "src/index.js"]
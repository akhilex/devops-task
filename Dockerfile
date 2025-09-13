# Use a builder stage to install all dependencies and run tests
FROM node:18.20.3-alpine AS builder

WORKDIR /usr/src/app

# Copy package.json and package-lock.json first for caching
COPY package*.json ./

# Install all dependencies (dev + prod) for building and testing
RUN npm ci

# Copy the rest of the application code
COPY . .

# Run the tests in the builder stage
RUN npm test

# Use a separate, minimal stage for the production image
FROM node:18.20.3-alpine AS final

# Set working directory for final image
WORKDIR /usr/src/app

# Copy only production dependencies from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy the rest of the application code from the builder stage
COPY . .

# Use a non-root user for security
USER node

# Expose port (default app port)
EXPOSE 3000

# Run the app
CMD ["npm", "start"]
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
# If this fails, the build will stop here.
RUN npm test

# Use a separate, minimal stage for the production image
FROM node:18.20.3-alpine AS final

# Set working directory for final image
WORKDIR /usr/src/app

# Only copy the essential files from the builder stage
COPY --from=builder /usr/src/app/. .

# Install only production dependencies for a lightweight image
RUN npm ci --only=production

# Use a non-root user for security
USER node

# Expose port (default app port)
EXPOSE 3000

# Run the app
CMD ["npm", "start"]

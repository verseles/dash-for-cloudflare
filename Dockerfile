# Use the official Node.js LTS Alpine image as a base
FROM node:lts-alpine

# Set the working directory
WORKDIR /srv/app

# Install Quasar CLI globally and netcat for healthcheck
RUN npm install -g @quasar/cli && \
    apk add --no-cache netcat-openbsd

# Copy package.json and package-lock.json to leverage Docker cache
COPY package*.json ./

# Install project dependencies without running scripts
RUN npm ci --ignore-scripts

# Copy the rest of the application's code
COPY . .

# Run the prepare script after all files are copied
RUN npm run postinstall

# Expose the port the app runs on (Quasar dev default port)
EXPOSE 9000

# The command to run the app
CMD ["quasar", "dev", "--host", "0.0.0.0", "--port", "9000"]

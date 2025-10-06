# Use the official Node.js LTS Alpine image as a base
FROM node:lts-alpine

# Set the working directory
WORKDIR /srv/app

# Install Quasar CLI globally and netcat for healthcheck
RUN npm install -g npm@latest && npm install -g @quasar/cli @quasar/icongenie && \
    apk add --no-cache netcat-openbsd

# Copy package.json and package-lock.json to leverage Docker cache
COPY package*.json ./

# Install project dependencies without running scripts
RUN npm install --ignore-scripts

# Copy the rest of the application's code
COPY . .

# Run quasar prepare after all files are copied
RUN npm run postinstall

# Expose the port the app runs on (Quasar dev default port)
EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=3s CMD nc -zv 0.0.0.0 9000 || exit 1

# The command to run the app (using npx to ensure it runs in foreground)
CMD ["npm", "run", "dev", "--host", "0.0.0.0", "--port", "9000"]

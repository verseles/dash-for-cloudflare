# Multi-stage Dockerfile for development and E2E testing
# Uses Playwright's official Ubuntu image for browser support

# =============================================================================
# Stage 1: Base with Node.js and Playwright browsers
# =============================================================================
FROM mcr.microsoft.com/playwright:v1.56.1-noble AS base

WORKDIR /srv/app

# Install Quasar CLI globally
RUN npm install -g npm@latest @quasar/cli @quasar/icongenie

# Copy package files first for better cache
COPY package*.json ./

# Install dependencies without running postinstall scripts
RUN npm ci --ignore-scripts

# Copy source code
COPY . .

# Run quasar prepare after all files are copied
RUN npm run postinstall

# =============================================================================
# Stage 2: Development server
# =============================================================================
FROM base AS dev

EXPOSE 1222

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -f http://localhost:1222 || exit 1

CMD ["npm", "run", "dev"]

# =============================================================================
# Stage 3: Run E2E tests
# =============================================================================
FROM base AS e2e

# Build the app for testing
RUN npm run build

# Run E2E tests (default: all browsers)
CMD ["npm", "run", "test:e2e"]

# =============================================================================
# Stage 4: Production build
# =============================================================================
FROM base AS build

RUN npm run build

# =============================================================================
# Stage 5: Production server (lightweight)
# =============================================================================
FROM nginx:alpine AS production

COPY --from=build /srv/app/dist/spa /usr/share/nginx/html

# Custom nginx config for SPA routing
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml; \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

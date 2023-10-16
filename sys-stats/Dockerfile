# --- Build Stage ---
FROM node:16.20.1-alpine as build-stage

# Set working directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# --- Production Stage ---
FROM nginx:alpine as production-stage

# Copy the built app from the build-stage to the nginx directory
COPY --from=build-stage /app/build /usr/share/nginx/html

# Expose port 80 for nginx
EXPOSE 80

# By default, nginx will start in the foreground, so there's no need for CMD ["nginx", "-g", "daemon off;"]
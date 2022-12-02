FROM alpine:latest
RUN apk --no-cache add git npm nodejs bash mysql-client mysql

WORKDIR /app

# Create node user so container doesn't run with root permissions
RUN addgroup -S node && adduser -S node -G node && \
    mkdir -p /app && chown -R node:node /app

# Copy contents of local src directory in repo into the /app WORKDIR of the container
COPY src /app/

RUN npm cache clean --force && \
  npm install

USER node

EXPOSE 8080

# Command on container startup to start node server and listen on Port 80
CMD node /app/index.js

FROM alpine:latest
RUN apk --no-cache add git npm nodejs bash

WORKDIR /app

RUN addgroup -S node && adduser -S node -G node && \
    mkdir -p /app && chown -R node:node /app

COPY src /app/

RUN npm cache clean --force && \
  npm install

USER node

EXPOSE 80

CMD node /app/index.js

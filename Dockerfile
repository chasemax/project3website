FROM alpine:latest
RUN apk --no-cache add git npm nodejs bash

WORKDIR /code

COPY src /code

RUN npm install

USER nodeuser

ENTRYPOINT ["node", "/code/src/index.js"]

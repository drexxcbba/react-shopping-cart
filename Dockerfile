FROM node:16-alpine 

WORKDIR /usr/src/app

RUN mkdir -p build

COPY build build

EXPOSE 3000

RUN npm install -g serve

CMD ["serve", "-s", "build"]

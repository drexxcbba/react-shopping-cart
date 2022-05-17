FROM node:16-alpine as builder

WORKDIR /usr/src/app

COPY . .

RUN npm install

RUN npm run build


FROM node:16-alpine 

WORKDIR /usr/src/app

RUN mkdir -p build

COPY --from=builder /usr/src/app/build build

EXPOSE 3000

RUN npm install -g serve

CMD ["serve", "-s", "build"]

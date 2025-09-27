FROM node:20-alpine

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install

COPY . .

# Build the application
RUN yarn build

EXPOSE 3000

CMD ["yarn", "start:prod"]

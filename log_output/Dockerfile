FROM node:alpine
WORKDIR /usr/src/app
COPY package* ./
RUN npm ci
COPY . .
ENV PINGPONG_URL="http://pingpong-svc:1234/counter"
CMD ["npm", "start"]
FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .
ARG DISCORD_WEBHOOK='https://study.cs.helsinki.fi/discord/webhooks/'
ENV DISCORD_WEBHOOK=${DISCORD_WEBHOOK}
CMD ["npm", "start"]
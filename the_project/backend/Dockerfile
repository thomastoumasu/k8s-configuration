FROM node:alpine
WORKDIR /usr/src/app
COPY package* ./
RUN npm ci
COPY . .
ARG ENVIRONMENT='staging'
ENV ENVIRONMENT=${ENVIRONMENT}
CMD ["npm", "start"]
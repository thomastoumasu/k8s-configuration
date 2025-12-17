FROM node:alpine AS build-stage 
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY --chown=node:node package* ./
RUN npm ci --omit=dev 
COPY --chown=node:node . .
# ENV VITE_BACKEND_URL=http://localhost:8081/api/todos
# ENV VITE_BACKEND_URL=http://localhost/api/todos
# ENV VITE_BACKEND_URL=http://34.88.70.145/api/todos
ENV VITE_BACKEND_URL=http://www.thomastoumasu.dpdns.org/api/todos
RUN npm run build
USER node

FROM nginx:1.25-alpine
# using default port 80 and /usr/share/nginx/html for nginx so no nginx.conf necessary
COPY --from=build-stage /usr/src/app/dist /usr/share/nginx/html
# no need for CMD, nginx starts up on its own

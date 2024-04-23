FROM node:20 AS build-env
COPY . /app
WORKDIR /app
RUN npm ci --omit=dev

FROM node:20-slim
COPY --from=build-env /app /app
WORKDIR /app
CMD ["node", "index.js"]

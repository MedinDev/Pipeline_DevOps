FROM --platform=$BUILDPLATFORM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM deps AS build
WORKDIR /app
COPY . .
RUN npm run build

FROM build AS test
WORKDIR /app
RUN npm test

FROM gcr.io/distroless/nodejs20-debian12 AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
EXPOSE 3000
CMD ["dist/server.js"]

FROM aquasec/trivy:0.59.1 AS security-scan
WORKDIR /scan
COPY --from=runtime /app /scan/app
RUN trivy fs --exit-code 0 --severity HIGH,CRITICAL /scan/app


FROM node:18-alpine


WORKDIR /app


RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodeuser -u 1001


COPY package*.json ./


RUN npm ci --only=production && npm cache clean --force


COPY . .


RUN mkdir -p public


RUN chown -R nodeuser:nodejs /app
USER nodeuser


EXPOSE 3000


HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1


CMD ["node", "app.js"]
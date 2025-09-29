# Usar imagen oficial de Node.js LTS
FROM node:18-alpine

# Establecer directorio de trabajo
WORKDIR /app

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodeuser -u 1001

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production && npm cache clean --force

# Copiar código fuente
COPY . .

# Crear directorio public si no existe
RUN mkdir -p public

# Cambiar propiedad de archivos al usuario nodejs
RUN chown -R nodeuser:nodejs /app
USER nodeuser

# Exponer puerto
EXPOSE 3000


HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1


CMD ["node", "app.js"]
# Imagen base ligera de Node.js
FROM node:18-alpine

# Crear directorio de trabajo
WORKDIR /usr/src/app

# Copiar package.json y package-lock.json primero (para aprovechar la cache)
COPY package*.json ./

# Instalar dependencias
RUN npm install --production

# Copiar todo el código de la aplicación
COPY . .

# Exponer el puerto en el que corre tu app (ajústalo si usas otro)
EXPOSE 3000

# Comando para iniciar tu servidor
CMD ["node", "app.js"]
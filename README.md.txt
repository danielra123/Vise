# Proyecto VISE 1.0

Este proyecto contiene la API *VISE, desarrollada en **Node.js* y lista para ejecutarse tanto de forma local como dentro de un contenedor *Docker*.  

---

## ⚙️ Requisitos previos
- Tener instalado [Node.js](https://nodejs.org/) (versión recomendada LTS).  
- Tener instalado [Docker](https://www.docker.com/) y [Docker Compose](https://docs.docker.com/compose/).  
- Editor recomendado: [Visual Studio Code](https://code.visualstudio.com/).  

---

##  Ejecución local (sin Docker)

1. Abrir la carpeta del proyecto en *Visual Studio Code*.  
2. Instalar dependencias (si aplica):  
   ```bash
   npm install

Ejecutar la aplicación:

node app.js


Abrir en el navegador:
 http://localhost:3000

=============================================================================================================

🐳 Ejecución con Docker

Verificar que existan los archivos:

Dockerfile

docker-compose.yml

Construir y levantar los contenedores:

docker-compose up --build -d


Abrir en el navegador:
 http://localhost:3000

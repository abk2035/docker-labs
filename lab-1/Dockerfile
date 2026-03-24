# Image de base
FROM node:20-alpine

# Specification du mainteneur
LABEL maintainer="Abk2035.."

# Dossier de travail
WORKDIR /app

# Copie des packages d'abord pour optimiser le cache Docker
COPY package.json ./

# Installation des dépendances (y compris nodemon)
RUN npm install

# Copie du reste du code source
COPY . .

# On expose le port
EXPOSE 3000

# On lance la commande 'dev' qui utilise nodemon
CMD ["npm", "start"]
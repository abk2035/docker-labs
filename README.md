# 🐳 Docker Labs & Containerization

Ce repository regroupe mes expérimentations, architectures et optimisations autour de l'écosystème Docker. L'objectif est de passer d'une simple conteneurisation à une gestion d'infrastructure robuste et performante.

---

## 🏗️ Projets & Labs

### 1. 🚀 Backend hello-worl nodejs et Express js 
Configuration D'un dockerfile pour application hello world nodejs-expressjs
- **Focus** : Build de l'image a partir d'un docker file.
- **Chemin** : `/lab1`

### 2. 🚀 Backend-frontend docker-compose application de vote 
build d'une application avec plusieurs services a partir de docker-compose
- **Focus** : Utilisation du docker-compose.
- **Chemin** : `/lab2`

### 2. 🚀 Backend docker-compose application FastApi + CI\CD 
construction d'un pipeline ci\cd avec jenkins ,docker et dpcker-compose
build d'une application avec plusieurs services a partir de docker-compose
- **Focus** : Utilisation du docker-compose + jenkins.
- **Chemin** : `/lab4`


### 3. 🛡️ Security & Hardening
Mise en pratique des bonnes méthodes de sécurité.
- **Focus** : Utilisation d'utilisateurs non-root, scan de vulnérabilités (Trivy), et gestion des secrets.
- **Chemin** : `/labs/security/`

---

## 🛠️ Concepts Maîtrisés

- [x] **Images** : Multi-stage builds, Alpine vs Debian, Layers optimization.
- [x] **Persistance** : Bind Mounts pour le dev, Volumes pour la prod.
- [x] **Networking** : Bridge networks, DNS interne, Reverse Proxy (Nginx).
- [x] **Orchestration** : Docker Compose avancé (Depends_on, Healthchecks).
- [ ] **Pipeline** : 



## 🚀 Comment lancer un lab ?

Chaque dossier contient son propre fichier `docker-compose.yml`. 
```bash
# Exemple pour le stack Odoo
cd labs/odoo-stack
docker-compose up -d

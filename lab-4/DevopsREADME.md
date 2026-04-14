# Rapport de Projet DevOps : Pipeline CI/CD automatisé pour une application FastAPI sur AWS

**Auteur :** Arnold Borele  
**Date :** 14 Avril 2026

---

## 📑 Table des matières
1. [Présentation du Projet](#présentation-du-projet)
2. [Architecture Technique](#architecture-technique)
3. [Étape 1 : Préparation de l'instance AWS EC2](#3-step-1-aws-ec2-instance-preparation)
4. [Étape 2 : Installer les dépendances sur EC2](#4-step-2-install-dependencies-on-ec2)
5. [Étape 3 : Installation et configuration de Jenkins](#5-step-3-jenkins-installation-and-setup)
6. [Étape 4 : Configuration du dépôt GitHub](#6-step-4-github-repository-configuration)
    * [Dockerfile](#dockerfile)
    * [docker-compose.yml](#docker-composeyml)
    * [Jenkinsfile](#jenkinsfile)
7. [Étape 5 : Création et exécution d'un pipeline Jenkins](#7-étape-5-création-et-exécution-d'un-pipeline-Jenkins)
8. [Conclusion](#8-conclusion)
9. [Conclusion](#conclusion)

---

## Présentation du Projet
Ce document décrit étape par étape la procédure de déploiement d'une application web (FastApi + PostgresSQL) sur une instance AWS EC2. Le déploiement est conteneurisé à l'aide de Docker et de Docker Compose. Un pipeline CI/CD complet est mis en place à l'aide de Jenkins afin d'automatiser les processus de compilation et de déploiement chaque fois qu'un nouveau code est poussé vers un dépôt GitHub.

---
## Architecture Technique

```
+-----------------+      +----------------------+      +-----------------------------+
|    Développeur  |----->|   Dépôt GitHub       |----->|      Serveur Jenkins        |
|  (push du code) |      | (Gestion de source)  |      |       (sur AWS EC2)         |
+-----------------+      +----------------------+      |                             |
                                                       | 1. Clone le dépôt           |
                                                       | 2. Construit l'image Docker |
                                                       | 3. Lance Docker Compose     |
                                                       +--------------+--------------+
                                                                      |
                                                                      | Déploie
                                                                      v
                                                       +-----------------------------+
                                                       |    Serveur d'Application    |
                                                       |       (Même EC2 AWS)        |
                                                       |                             |
                                                       | +-------------------------+ |
                                                       | | Conteneur : FastAPI     | |
                                                       | +-------------------------+ |
                                                       |               |             |
                                                       |               v             |
                                                       | +-------------------------+ |
                                                       | | Conteneur : PostgreSQL  | |
                                                       | +-------------------------+ |
                                                       +-----------------------------+

```



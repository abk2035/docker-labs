# TP SUR KUBERNETES, EKS,AWS


## PROGRAMME

✅ Créé son cluster EKS avec Fargate  
✅ Configuré le OIDC provider (s3, etc.)  
✅ Créé la IAM policy et le service account  
✅ Déployé le AWS Load Balancer Controller  
✅ Déployé ton Deployment, Service et Ingress

## PREREQUIS

- kubectl – Un outil en ligne de commande pour travailler avec les clusters Kubernetes. Pour plus d'informations, voir [Installation ou mise à jour de kubectl].

- eksctl – Un outil en ligne de commande pour gérer les clusters EKS, qui automatise de nombreuses tâches individuelles.

- AWS CLI – Un outil en ligne de commande pour interagir avec les services AWS, y compris Amazon EKS. Pour plus d'informations, voir [Installation, mise à jour et désinstallation de l'AWS CLI] dans le Guide de l'utilisateur AWS Command Line Interface. Après l'installation de l'AWS CLI, il est recommandé de la configurer. Pour plus d'informations, voir [Configuration rapide avec aws configure] dans le même guide.

NB : consulter la documentation de chaque ressource pour les etapes d'installation

---

## **Installer EKS**

Suivre la partie des **prérequis** avant cette étape.

---

### ✅ **Installation avec Fargate**

```bash
eksctl create cluster --name demo-cluster --region us-west-2 --fargate
```

> Cette commande crée un cluster EKS nommé `demo-cluster` dans la région `us-west-2`, en utilisant **Fargate** (mode sans gestion de nœuds EC2, les pods sont directement exécutés sur des ressources managées).

---

### ❌ **Supprimer le cluster**

```bash
eksctl delete cluster --name demo-cluster --region us-west-2
```

> Cette commande supprime le cluster EKS nommé `demo-cluster`.

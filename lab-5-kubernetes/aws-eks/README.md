# TP SUR KUBERNETES, EKS,AWS


## PROGRAMME

✅ Créé son cluster EKS avec Fargate  
✅ Configuré le OIDC provider (s3, etc.)  
✅ Créé la IAM policy et le service account  
✅ Déployé le AWS Load Balancer Controller  
✅ Déployé ton Deployment, Service et Ingress

## CREER SON CLUSTER EKS AVEC FARGATE

### PREREQUIS

- kubectl – Un outil en ligne de commande pour travailler avec les clusters Kubernetes. Pour plus d'informations, voir [Installation ou mise à jour de kubectl].

- eksctl – Un outil en ligne de commande pour gérer les clusters EKS, qui automatise de nombreuses tâches individuelles.

- AWS CLI – Un outil en ligne de commande pour interagir avec les services AWS, y compris Amazon EKS. Pour plus d'informations, voir [Installation, mise à jour et désinstallation de l'AWS CLI] dans le Guide de l'utilisateur AWS Command Line Interface. Après l'installation de l'AWS CLI, il est recommandé de la configurer. Pour plus d'informations, voir [Configuration rapide avec aws configure] dans le même guide.

NB : consulter la documentation de chaque ressource pour les etapes d'installation

---

### **Installer EKS**

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

## Configuré le OIDC provider (s3, etc.)

### 🧠 **1. Contexte : C’est quoi IAM OIDC dans EKS ?**

🔐 IAM (Identity and Access Management)

C’est le service AWS qui te permet de **gérer les permissions** : qui peut faire quoi, sur quelles ressources.

🌐 OIDC (OpenID Connect)

OIDC est un protocole d’authentification basé sur OAuth 2.0. Dans le contexte EKS, **AWS utilise OIDC pour permettre à Kubernetes de s’authentifier auprès d’AWS IAM**.

🎯 **Pourquoi c’est important ?**

Dans un cluster EKS, tu peux permettre à un **pod Kubernetes** (via un **ServiceAccount**) d'assumer un **rôle IAM spécifique**. Mais pour cela, tu dois d'abord :

Associer un fournisseur OIDC à ton cluster EKS, pour qu’AWS "reconnaisse" les demandes d’authentification faites depuis Kubernetes.

---

### ⚙️ **2. Étapes de configuration du fournisseur IAM OIDC**

📌 **Étape 1 : Définir le nom de ton cluster**

```bash
export cluster_name=demo-cluster
```

➡️ Cela définit une variable d’environnement appelée `cluster_name`. Elle contient le nom de ton cluster EKS (`demo-cluster`) pour qu’on puisse la réutiliser facilement dans les autres commandes.


🔍 **Étape 2 : Récupérer l’ID OIDC du cluster**

```bash
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
```

➡️ Explication :

* `aws eks describe-cluster` : demande à AWS les détails de ton cluster.
* `--query "cluster.identity.oidc.issuer"` : extrait uniquement l’URL du fournisseur OIDC.
* `cut -d '/' -f 5` : garde seulement l’**identifiant unique** du fournisseur.

📦 Exemple de sortie :
Si l’URL retournée est :

```
https://oidc.eks.us-west-2.amazonaws.com/id/abc123xyz456
```

alors `oidc_id = abc123xyz456`.

 ✅ **Étape 3 : Vérifier si le fournisseur est déjà configuré**

```bash
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
```

➡️ Cette commande :

* Liste tous les fournisseurs OIDC enregistrés dans IAM.
* Cherche si l’un d’eux correspond à ton `oidc_id`.

📌 **Si tu obtiens une sortie** (ex : `abc123xyz456`), alors **le fournisseur est déjà associé**.


🔧 **Étape 4 : Associer le fournisseur OIDC si ce n’est pas encore fait**

```bash
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
```

➡️ Cette commande :

* Associe officiellement ton cluster EKS à un **fournisseur d’identité OIDC**.
* Permet ensuite à tes pods d’utiliser les **IAM Roles for ServiceAccounts (IRSA)**.

> ✅ Cette configuration est **essentielle** pour permettre à certaines applications (ex. AWS Load Balancer Controller, CSI drivers, etc.) de fonctionner **sans partager de clés d’accès AWS**.

---

🧩 Exemple d’utilisation concrète après cette configuration

Une fois le fournisseur OIDC configuré :

* Tu peux créer un **ServiceAccount Kubernetes** avec une **annotation spéciale** qui pointe vers un rôle IAM.
* Ce rôle IAM peut, par exemple, **accéder à S3, ECR, CloudWatch**, etc.
* Et tout ça, **sans clé d’accès** : le pod "assume" le rôle de manière sécurisée via OIDC.

---

### 📌 Résumé visuel

| Étape | Action                                         | Objectif                          |
| ----- | ---------------------------------------------- | --------------------------------- |
| 1     | `export cluster_name=demo-cluster`             | Définir le nom du cluster         |
| 2     | Récupérer `oidc_id`                            | Identifier l’URL OIDC du cluster  |
| 3     | Vérifier avec `list-open-id-connect-providers` | Savoir si OIDC est déjà configuré |
| 4     | `eksctl utils associate-iam-oidc-provider`     | Configurer OIDC si besoin         |



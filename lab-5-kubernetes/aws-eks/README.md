# TP SUR KUBERNETES, EKS,AWS


## PROGRAMME

✅ Créé son cluster EKS avec Fargate  
✅ Configuré le OIDC provider (s3, etc.)  
✅ Créé la IAM policy et le service account  
✅ Déployé le AWS Load Balancer Controller  
✅ Déployé ton Deployment, Service et Ingress

## ✅ CREER SON CLUSTER EKS AVEC FARGATE

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



### ❌ **Supprimer le cluster**

```bash
eksctl delete cluster --name demo-cluster --region us-west-2
```

> Cette commande supprime le cluster EKS nommé `demo-cluster`.

---
 
## ✅ Configuré le OIDC provider (s3, etc.)

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

---

## 🛠️ Installer et Configurer AWS Load Balancer Controller sur EKS ( Créé la IAM policy et le service account )

Le **AWS Load Balancer Controller** permet à votre cluster **EKS** de créer automatiquement des **Application Load Balancers (ALB)** et de les configurer à partir de ressources **Ingress** dans Kubernetes. Ce guide vous montre étape par étape comment :

* Configurer IAM OIDC
* Créer les rôles et politiques nécessaires
* Déployer le contrôleur avec Helm
* Vérifier l'installation

### ✅ Étape 1 – Préparer l’environnement

#### 1.1 Définir le nom du cluster

```bash
export CLUSTER_NAME=demo-cluster
export AWS_REGION=us-west-2
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
```

---

### 🔐 Étape 2 – Activer IAM OIDC pour le cluster

```bash
eksctl utils associate-iam-oidc-provider \
  --region $AWS_REGION \
  --cluster $CLUSTER_NAME \
  --approve
```

---

### 📜 Étape 3 – Créer la politique IAM complète pour ALB Controller

#### 3.1 Créer un fichier `alb_iam_policy.json` avec le contenu suivant :

```bash
cat <<EOF > alb_iam_policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["iam:CreateServiceLinkedRole"],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeVpcs",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeTags",
        "ec2:GetCoipPoolUsage",
        "ec2:DescribeCoipPools",
        "ec2:GetSecurityGroupsForVpc",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTrustStores",
        "elasticloadbalancing:DescribeListenerAttributes",
        "elasticloadbalancing:DescribeCapacityReservation"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient",
        "acm:ListCertificates",
        "acm:DescribeCertificate",
        "iam:ListServerCertificates",
        "iam:GetServerCertificate",
        "waf-regional:GetWebACL",
        "waf-regional:GetWebACLForResource",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL",
        "wafv2:GetWebACL",
        "wafv2:GetWebACLForResource",
        "wafv2:AssociateWebACL",
        "wafv2:DisassociateWebACL",
        "shield:GetSubscriptionState",
        "shield:DescribeProtection",
        "shield:CreateProtection",
        "shield:DeleteProtection"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:CreateSecurityGroup"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:CreateTags"],
      "Resource": "arn:aws:ec2:*:*:security-group/*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "CreateSecurityGroup"
        },
        "Null": {
          "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:CreateTags", "ec2:DeleteTags"],
      "Resource": "arn:aws:ec2:*:*:security-group/*",
      "Condition": {
        "Null": {
          "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
          "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:DeleteRule"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags"],
      "Resource": [
        "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
        "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
        "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
      ],
      "Condition": {
        "Null": {
          "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
          "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags"],
      "Resource": [
        "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
        "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
        "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
        "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:ModifyListenerAttributes",
        "elasticloadbalancing:ModifyCapacityReservation"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:AddTags"],
      "Resource": [
        "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
        "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
        "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
      ],
      "Condition": {
        "StringEquals": {
          "elasticloadbalancing:CreateAction": [
            "CreateTargetGroup",
            "CreateLoadBalancer"
          ]
        },
        "Null": {
          "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets"],
      "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:SetWebAcl",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:ModifyRule"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```

#### 3.2 Créer la politique IAM dans AWS

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://alb_iam_policy.json
```

---

### 🎭 Étape 4 – Créer le rôle IAM et le ServiceAccount Kubernetes

```bash
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --region=$AWS_REGION \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

---

## ✅ Déployé le AWS Load Balancer Controller

### 📦 Étape 5 – Installer le contrôleur ALB avec Helm

#### 5.1 Ajouter le dépôt Helm

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

#### 5.2 Installer le contrôleur

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set region=$AWS_REGION \
  --set vpcId=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.vpcId" --output text) \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

---

### ✅ Étape 6 – Vérification du déploiement

#### 6.1 Vérifier que le déploiement est actif

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

#### 6.2 Redémarrer le contrôleur (si modification de la politique IAM)

```bash
kubectl rollout restart deployment aws-load-balancer-controller -n kube-system
```

#### 6.3 Consulter les journaux

```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

---

### 🧪 Étape 7 – Tester avec un Ingress

Une fois installé, vous pouvez déployer un **Ingress** Kubernetes dans un namespace quelconque, et le contrôleur créera automatiquement un **ALB** pour gérer le trafic entrant.

## ✅ Déployé le Deployment, Service et Ingress

### 🎯 Objectif

Déployer le jeu 2048 dans un cluster Amazon EKS en utilisant AWS Fargate pour exécuter les pods sans gérer d'infrastructure serveur, et exposer l'application via un Application Load Balancer (ALB) grâce à AWS Load Balancer Controller.

---

### 🛠️ Étapes de déploiement

#### 1. **Créer un profil Fargate**

```bash
eksctl create fargateprofile \
  --cluster demo-cluster \
  --region us-west-2 \
  --name alb-sample-app \
  --namespace game-2048
```

Cette commande crée un profil Fargate nommé `alb-sample-app` pour le cluster `demo-cluster` dans la région `us-west-2`. Ce profil spécifie que tous les pods déployés dans le namespace `game-2048` seront exécutés sur AWS Fargate, éliminant ainsi le besoin de gérer des instances EC2.

---

#### 2. **Déployer l'application 2048**

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml
```

Cette commande applique les ressources définies dans le fichier YAML, qui comprend :

* **Namespace** : `game-2048`
* **Deployment** : déploie 5 réplicas du conteneur `docker-2048`
* **Service** : expose l'application sur le port 80
* **Ingress** : configure un ALB pour exposer l'application sur Internet

---

### 📄 Contenu du fichier `2048_full.yaml`

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: game-2048
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: game-2048
  name: deployment-2048
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: app-2048
  replicas: 5
  template:
    metadata:
      labels:
        app.kubernetes.io/name: app-2048
    spec:
      containers:
      - image: public.ecr.aws/l6m2t8p7/docker-2048:latest
        imagePullPolicy: Always
        name: app-2048
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  namespace: game-2048
  name: service-2048
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: NodePort
  selector:
    app.kubernetes.io/name: app-2048
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: game-2048
  name: ingress-2048
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: service-2048
              port:
                number: 80
```

---

### 🔍 Explication des composants

* **Namespace `game-2048`** : isole les ressources liées à l'application 2048.
* **Deployment `deployment-2048`** : déploie 5 instances du conteneur `docker-2048`.
* **Service `service-2048`** : expose l'application en interne sur le port 80.
* **Ingress `ingress-2048`** : configure un ALB pour exposer l'application sur Internet. Les annotations spécifient que l'ALB est orienté vers Internet et que les cibles sont des adresses IP (adapté à Fargate).

---

## 🌐 Accéder à l'application

Après quelques minutes, l'ALB sera provisionné. Pour obtenir l'adresse DNS de l'Ingress :

```bash
kubectl get ingress ingress-2048 -n game-2048
```

La colonne `ADDRESS` affichera le nom DNS de l'ALB. Vous pouvez accéder à l'application en ouvrant cette URL dans votre navigateur.

## ✅ Supprimer les Ressources creees

### 🧨 Étape 1 – Supprimer l’application déployée (Deployment, Service, Ingress)

```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml
```

---

### 🧨 Étape 2 – Supprimer le Fargate Profile

Tu dois supprimer **chaque Fargate profile** attaché au cluster :

```bash
eksctl delete fargateprofile --cluster demo-cluster --name alb-sample-app --region us-west-2
```

*Adapte `alb-sample-app` au nom réel de ton Fargate profile si besoin.*

---

### 🧨 Étape 3 – Supprimer le contrôleur ALB

Si tu l’as installé avec Helm :

```bash
helm uninstall aws-load-balancer-controller -n kube-system
```

---

### 🧨 Étape 4 – Supprimer le Service Account IAM

```bash
eksctl delete iamserviceaccount \
  --cluster demo-cluster \
  --name aws-load-balancer-controller \
  --namespace kube-system
```

---

### 🧨 Étape 5 – Supprimer la IAM Policy manuellement (facultatif mais propre)

Liste les policies :

```bash
aws iam list-policies | grep AWSLoadBalancerControllerIAMPolicy
```

Supprime la policy si elle n’est plus utilisée :

```bash
aws iam delete-policy --policy-arn arn:aws:iam::<votre-id>:policy/AWSLoadBalancerControllerIAMPolicy
```

---

### 🧨 Étape 6 – Supprimer le cluster EKS

```bash
eksctl delete cluster --name demo-cluster --region us-west-2
```

---

### 🧨 Étape 7 – Vérifie que tout est bien supprimé

Tu peux aller dans la **console AWS** (EC2, IAM, EKS, VPC) pour confirmer qu'il ne reste :

* Aucun ALB
* Aucun VPC ou Security Group créé par EKS (optionnel)
* Aucune IAM Policy résiduelle






## ⚙️ **Minikube Lifecycle Commands**

| Action                                    | Command                          |
| ----------------------------------------- | -------------------------------- |
| Start the cluster                         | `minikube start --driver=docker` |
| Stop the cluster (pause without deleting) | `minikube stop`                  |
| Check Minikube status                     | `minikube status`                |
| Delete cluster completely                 | `minikube delete`                |
| Show cluster IP                           | `minikube ip`                    |
| Show installed addons                     | `minikube addons list`           |
| Launch dashboard UI                       | `minikube dashboard`             |

---

## 🧠 **Cluster Information Commands**

| Action                              | Command                          |
| ----------------------------------- | -------------------------------- |
| View cluster info                   | `kubectl cluster-info`           |
| View node(s) info                   | `kubectl get nodes`              |
| Describe node details               | `kubectl describe node minikube` |
| View all pods across all namespaces | `kubectl get pods -A`            |
| View all services in all namespaces | `kubectl get svc -A`             |
| View kubeconfig context             | `kubectl config view`            |
| See current context                 | `kubectl config current-context` |

---

## 📝 Save all cluster info

```bash
kubectl cluster-info > cluster-info.txt && \
kubectl get nodes >> cluster-info.txt && \
kubectl get pods -A >> cluster-info.txt && \
kubectl config view >> cluster-info.txt
```
---

## 📦 **Pod Lifecycle with `kubectl`**


## 📦 Create a Pod

| Method                                 | Command                               |
| -------------------------------------- | ------------------------------------- |
| Create Pod from image (one-liner)      | `kubectl run nginx-pod --image=nginx` |
| Create Pod from YAML                   | `kubectl apply -f pod.yaml`           |
| Create Pod with `create` (alternative) | `kubectl create -f pod.yaml`          |

---

## ❌ Delete a Pod

| Description              | Command                                                  |
| ------------------------ | -------------------------------------------------------- |
| Delete a specific Pod    | `kubectl delete pod <pod-name>`                          |
| Force delete immediately | `kubectl delete pod <pod-name> --grace-period=0 --force` |

---

## 🔁 Restart a Pod

> Kubernetes has **no direct "restart"**, but here are two options:

| Method                                                    | Command                                                      |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| Delete and let a controller (like Deployment) recreate it | `kubectl delete pod <pod-name>`                              |
| Manual restart (no controller)                            | `kubectl delete pod <pod-name> && kubectl apply -f pod.yaml` |

✅ If the Pod is part of a **Deployment**, it will auto-recreate after delete.

---

## 🧠 Pod Logs and Debugging

| Action                              | Command                                       |
| ----------------------------------- | --------------------------------------------- |
| View logs from a Pod                | `kubectl logs <pod-name>`                     |
| View logs from a specific container | `kubectl logs <pod-name> -c <container-name>` |
| Stream logs (real-time)             | `kubectl logs -f <pod-name>`                  |

---

## 💻 Access Inside the Pod

| Description                     | Command                                    |
| ------------------------------- | ------------------------------------------ |
| Access terminal (bash)          | `kubectl exec -it <pod-name> -- /bin/bash` |
| Access terminal (sh)            | `kubectl exec -it <pod-name> -- /bin/sh`   |
| Run a one-time command in a Pod | `kubectl exec <pod-name> -- ls /`          |


## 🌍 Access the Pod from Localhost

| Method                        | Command                                       |
| ----------------------------- | --------------------------------------------- |
| Port forward Pod to localhost | `kubectl port-forward pod/<pod-name> 8080:80` |
| Access in browser             | Open `http://localhost:8080`                  |


## 🔍 View and Inspect Pods

| Description                             | Command                              |
| --------------------------------------- | ------------------------------------ |
| List all Pods                           | `kubectl get pods`                   |
| List all Pods with more info (node, IP) | `kubectl get pods -o wide`           |
| View Pods in all namespaces             | `kubectl get pods -A`                |
| Show details of a Pod                   | `kubectl describe pod <pod-name>`    |
| Show Pod YAML definition                | `kubectl get pod <pod-name> -o yaml` |


---

## 📁 Example: Simple Pod YAML (`nginx-pod.yaml`)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
```

Create it:

```bash
kubectl apply -f nginx-pod.yaml
```

---
## ♻️ 2.3 ReplicaSet

Un **ReplicaSet** permet d’assurer qu’un nombre donné de **répliques de Pods** sont toujours en cours d’exécution.

💡 Si un Pod tombe, un nouveau est créé automatiquement.

**Exemple** :

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
```

---

## 📦 **Deployment Lifecycle with `kubectl`**

Un **Deployment** est l’objet Kubernetes **le plus utilisé pour déployer une application**. Il permet :

* Des **mises à jour progressives** (rolling updates)
* Des **rollbacks**
* De gérer les **ReplicaSets automatiquement**

**Exemple de déploiement** :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.21
```
## ✅ Bonnes Pratiques de Déploiement dans Kubernetes

| Bonne Pratique ✅                            | Explication                             |
| ------------------------------------------- | --------------------------------------- |
| Utilisez des **Deployments**                | Pas de Pods seuls en prod               |
| Ajoutez des **probes** (readiness/liveness) | Pour vérifier la santé des applications |
| Définissez les **ressources** (CPU/mémoire) | Pour éviter de saturer le cluster       |
| Stockez la config via **ConfigMaps**        | Pour séparer config et code             |
| Stockez les secrets via **Secrets**         | Pour les mots de passe, tokens, etc.    |
| Utilisez des **labels intelligents**        | Pour filtrer, scaler et monitorer       |
| Ne jamais utiliser `latest` en prod         | Versionnez vos images                   |
| Mettez en place un **autoscaler**           | Horizontal Pod Autoscaler (HPA)         |
| Organisez vos ressources par **namespace**  | dev, staging, prod                      |

---
## ✅ Les Services dans Kubernetes

## 🧠 1. Pourquoi les Services existent ?

### 📍 Problème à résoudre

* Les Pods dans Kubernetes sont **éphémères** : si un Pod meurt, il est recréé avec une **nouvelle IP**.
* Impossible de **s’adresser à un Pod directement** de manière fiable dans le temps.
* Kubernetes a besoin d’un moyen de **stabiliser l’accès réseau** à une application.

### ✅ Solution : le **Service**

Un **Service** dans Kubernetes est une **abstraction réseau stable** qui permet :

* De communiquer avec un groupe de Pods de manière **fiable et permanente**.
* De **découvrir automatiquement** les applications (service discovery).
* De **répartir la charge (load balancing)** entre les Pods associés.

---

## 🧩 Fonctionnement du Service

* Un Service cible un groupe de **Pods associés par des labels**.
* Il crée une **IP virtuelle stable** (ClusterIP) + un **nom DNS interne**.
* Il utilise un **proxy interne (kube-proxy)** pour diriger le trafic vers les Pods.
*

---

## 🔍 3. Types de Services Kubernetes

| Type           | Accessible depuis                      | Load balancing | IP stable ? | Utilisation typique                         |
| -------------- | -------------------------------------- | -------------- | ----------- | ------------------------------------------- |
| `ClusterIP`    | Interne au cluster                     | ✅ Oui          | ✅ Oui       | Communication entre services internes       |
| `NodePort`     | Depuis l’extérieur via un port du nœud | ✅ Oui          | ✅ Oui       | Accès externe simple                        |
| `LoadBalancer` | Internet (via un Cloud Provider)       | ✅ Oui          | ✅ Oui       | Accès public scalable via un LB cloud       |
| `ExternalName` | Redirection DNS                        | ❌              | ❌           | Lien vers un service externe (ex: API SaaS) |

---

### 🟢 1. **ClusterIP** (le **type par défaut**)

Permet à d'autres **applications dans le même cluster** de communiquer avec les Pods **via une IP virtuelle stable**.


### 🧪 Exemple :

Tu as un backend (Django) et un frontend (React). Le frontend appelle le backend via l'adresse DNS du service :

```
http://mon-backend-service.default.svc.cluster.local
```

---

### 🟠 2. **NodePort**

Expose ton application **vers l’extérieur du cluster**, en **ouvrant un port sur chaque machine (nœud)**.

#### 🌐 Accessibilité :

* ✅ Accessible depuis **ton navigateur**, par l'IP du nœud + le port.
* Port entre **30000–32767** automatiquement attribué (ou défini manuellement).

#### 📍 URL d’accès :

```
http://<IP-du-nœud>:<nodePort>
```

> Ex : `http://192.168.99.100:30036`

#### 🧪 Exemple :

Parfait pour tester un service en local avec Minikube :

```bash
kubectl expose deployment monapp --type=NodePort --port=80
```

---

### 🔵 3. **LoadBalancer**

Expose l’application **vers Internet via une IP publique**. Utilisé en **production sur un cloud** (AWS, GCP, Azure...).

#### 🌐 Accessibilité :

* ✅ Accessible **depuis l'extérieur du cluster** via une IP **publique** attribuée automatiquement.

#### ⚙️ Nécessite :

Un **Cloud Provider** qui gère un Load Balancer (comme AWS ELB).

### 🔁 Load balancing :

✅ Oui. Le Load Balancer cloud répartit les requêtes vers les nœuds → kube-proxy → Pods.

#### 🧪 Exemple :

```bash
kubectl expose deployment monapp --type=LoadBalancer --port=80
```

> Sur Minikube, `minikube service monapp` simule un LoadBalancer localement.

---

### 🟣 4. **ExternalName**

Créer un **alias DNS interne** vers un **service externe** (ex : une API SaaS).

### 🌐 Accessibilité :

* ❌ Pas un proxy réel : **pas de load balancing, ni redirection réseau**.
* Juste une redirection **DNS** dans le cluster.

#### 📍 Exemple :

Tu veux accéder à une API externe comme :

```text
api.openai.com
```

Tu crées un service Kubernetes :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-openai
spec:
  type: ExternalName
  externalName: api.openai.com
```

Dans le cluster, tous les Pods peuvent appeler :

```
http://api-openai.default.svc.cluster.local
```

Et ça redirige vers `api.openai.com`.

---




## 📜 4. Exemple YAML pour chaque type

### 🟢 ClusterIP (par défaut)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mon-service
spec:
  selector:
    app: monapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

> 🧠 Redirige les requêtes sur `mon-service:80` vers les Pods qui ont `app: monapp` sur le port 8080.

---

### 🟠 NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mon-service
spec:
  type: NodePort
  selector:
    app: monapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 30036
```

> Permet d’accéder à l’app via `http://<NodeIP>:30036` depuis l’extérieur du cluster.

---

### 🔵 LoadBalancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mon-service
spec:
  type: LoadBalancer
  selector:
    app: monapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

> Utilise le Load Balancer de ton cloud provider (ex : AWS ELB, GCP LB) pour exposer l’app sur Internet.

---

### 🟣 ExternalName

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mon-service-externe
spec:
  type: ExternalName
  externalName: api.exemple.com
```

> Crée un alias DNS dans le cluster : `mon-service-externe.default.svc.cluster.local` → `api.exemple.com`.

---

## 🌐 5. Découverte de services (Service Discovery)

### 📦 DNS automatique

Chaque Service a un **nom DNS interne** :

```
<nom-service>.<namespace>.svc.cluster.local
```

Exemple :

```bash
curl http://mon-service.default.svc.cluster.local
```

Tu peux aussi utiliser simplement :

```bash
curl http://mon-service
```

si tu es dans le même namespace.

---

## ⚖️ 6. Load Balancing interne

Kubernetes utilise **kube-proxy** :

* Il écoute les ports ouverts par les Services.
* Il redirige le trafic vers un Pod sélectionné **aléatoirement ou en round-robin**.

✅ Il équilibre la charge entre les Pods cibles automatiquement.

---

## 🚀 7. Commandes utiles avec Services

| Commande                                                                        | Description                 |
| ------------------------------------------------------------------------------- | --------------------------- |
| `kubectl get svc`                                                               | Voir tous les Services      |
| `kubectl describe svc mon-service`                                              | Détails du Service          |
| `kubectl expose deployment monapp --port=80 --target-port=8080 --type=NodePort` | Créer un Service rapidement |
| `kubectl delete svc mon-service`                                                | Supprimer un Service        |

---

## ✅ 8. Bonnes pratiques

| Bonne Pratique                                                | Pourquoi ?                                     |
| ------------------------------------------------------------- | ---------------------------------------------- |
| Toujours utiliser des labels cohérents (`app`, `tier`, `env`) | Pour bien associer les Pods au Service         |
| Utiliser `ClusterIP` pour les communications internes         | Plus sécurisé et rapide                        |
| Éviter d’exposer des ports en `NodePort` sans firewall        | Risque de faille de sécurité                   |
| Sur le Cloud, préférer `LoadBalancer` ou `Ingress`            | Pour une gestion avancée                       |
| Activer les **readiness probes** sur les Pods                 | Évite d’envoyer du trafic à des Pods non prêts |









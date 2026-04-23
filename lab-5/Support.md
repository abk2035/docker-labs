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





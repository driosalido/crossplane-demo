# crossplane-demo

## Deploy Kind K8s 

We are going to use kind to deploy a local k8s cluster with cert-managaer a nginx-ingress controller

Install Kind

```sh 
kind create cluster --config=./kind/kind.yaml --name control-plane
```

Install Cert-Manager and cert-issuer resource
```sh 
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
kubectl apply -f ./kind/cert-issuer.yaml
```

Deploy Ingress Controller
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

And wait until the ingress-nginx controller is deployed

```sh
kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-bc7kp        0/1     Completed   0          35s
ingress-nginx-admission-patch-pg7s2         0/1     Completed   0          35s
ingress-nginx-controller-7785c7547c-dz5sn   1/1     Running     0          35s
```

## Deploy ArgoCD

Deploy ArgoCD
```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait until argocd is fully deployed
```sh
kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          71s
argocd-applicationset-controller-7796bb8958-pcs68   1/1     Running   0          71s
argocd-dex-server-77dcfd899c-ggfq2                  1/1     Running   0          71s
argocd-notifications-controller-d89bc56c-ngwsj      1/1     Running   0          71s
argocd-redis-86df6b8979-krd66                       1/1     Running   0          71s
argocd-repo-server-8457cf44dc-rf5lx                 1/1     Running   0          71s
argocd-server-57d47d5885-lrdlw                      1/1     Running   0          71s
```

Install the ArgoCD Command Line
```sh
brew install argocd
```

Expose the ArgoCD API Server using ngix-ingress
```sh
kubectl apply -n argocd -f ./argocd/ingress.yaml
```

And add the following line to your `/etc/hosts` file

```
127.0.0.1       localhost argocd.local
```

Get the argocd admin password from the k8s secret
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
XXXXXXXX
```

Change the Admin password 
```sh
argocd login argocd.local
WARNING: server certificate had error: x509: “argocd.local” certificate is not trusted. Proceed insecurely (y/n)? y
WARN[0001] Failed to invoke grpc call. Use flag --grpc-web in grpc calls. To avoid this warning message, use flag --grpc-web.
Username: admin
Password:
'admin:login' logged in successfully
Context 'argocd.local' updated

argocd account update-password
WARN[0000] Failed to invoke grpc call. Use flag --grpc-web in grpc calls. To avoid this warning message, use flag --grpc-web.
*** Enter password of currently logged in user (admin):
*** Enter new password for user admin:
*** Confirm new password for user admin:
Password updated
Context 'argocd.local' updated

```

Remove the secret with the admin password as is not longer needed
```sh
kubectl delete secret -n argocd argocd-initial-admin-secret
secret "argocd-initial-admin-secret" deleted
```

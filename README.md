# crossplane-demo

## Deploy Kind K8s 

We are going to use kind to deploy a local k8s cluster with cert-managaer a nginx-ingress controller

Install Kind

```sh 
kind create cluster --config=bootstrap/kind.yaml --name control-plane
```

Install Cert-Manager and cert-issuer resource
```sh 
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
kubectl apply -f ./bootstrap/cert-issuer.yaml
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

## Install ArgoCD

Generate Chart

```sh 
helm dep update charts/argo-cd/
git add charts/argo-cd
git commit -m 'add argo-cd chart'
git push
```

Install ArgoCD
```sh
helm install --create-namespace --namespace argocd argo-cd charts/argo-cd/ 
```

Expose the ArgoCD API Server using ngix-ingress
```sh
kubectl apply -n argocd -f ./bootstrap/ingress.yaml
```

And add the following line to your `/etc/hosts` file

```
127.0.0.1       localhost argocd.local
```

Get the argocd admin password from the k8s secret
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n argocd | base64 -d; echo
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

We can then visit https://argocd.local to access it.


Deploy root app
```
helm template apps/ | kubectl apply -n argocd -f -
```

Remove helm deployment state
```sh 
kubectl delete secret -n argocd -l owner=helm,name=argo-cd
```


CROSSPLANE


helm install crossplane --create-namespace --namespace crossplane-system crossplane-stable/crossplane

kubectl create secret generic aws-creds -n crossplane-system --from-file=creds=./aws-creds.conf





❯ kubectl crossplane install configuration driosalido/getting-started-with-aws:v1.8.0


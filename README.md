# argoCD (deployment)
for run in minikube 
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:80

http://<VM_IP>:8080

for pass
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xargs printf "%s\n"

# tetris
ubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8081:80
http://<VM_IP>:8081
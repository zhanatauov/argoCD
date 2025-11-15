# argoCD 
for run in minikube (after install)
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:80

http://<VM_IP>:8080

for password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xargs printf "%s\n"

# tetris
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8081:80
http://<VM_IP>:8081
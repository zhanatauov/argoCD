#!/bin/bash

exec > /var/log/bootstrap.log 2>&1

# Оновлення системи
apt update && apt upgrade -y
apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release net-tools git conntrack

# Встановлення Docker
curl -fsSL https://get.docker.com | bash
usermod -aG docker ubuntu

# Встановлення crictl
VERSION="v1.28.0"
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz
sudo tar -C /usr/local/bin -xzf crictl-${VERSION}-linux-amd64.tar.gz
rm crictl-${VERSION}-linux-amd64.tar.gz

# Встановлення kubectl
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Встановлення Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# systemd-сервіс для запуску Minikube
cat <<EOF > /etc/systemd/system/minikube-start.service
[Unit]
Description=Start Minikube Cluster
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/minikube start --driver=docker --memory=4096mb --wait=all --wait-timeout=5m
RemainAfterExit=true
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable minikube-start.service
systemctl start minikube-start.service

# Надання прав доступу
chown -R ubuntu:ubuntu /home/ubuntu/.kube /home/ubuntu/.minikube || true

# Очікування Minikube
until /usr/local/bin/minikube status | grep -q "host: Running"; do
  echo "Waiting for Minikube to be ready..."
  sleep 10
done

# Створення alias для kubectl
echo 'alias kubectl="minikube kubectl --"' >> /home/ubuntu/.bashrc

# Встановлення ArgoCD
/usr/local/bin/kubectl create namespace argocd || true
/usr/local/bin/kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Очікування
sleep 90

# Деплой ArgoCD Application
/usr/local/bin/kubectl apply -f https://raw.githubusercontent.com/Pavlo-1992/argoCD/main/argo_app/argocd-application.yaml -n argocd

# Systemd-сервіс для port-forward ArgoCD
cat <<EOF > /etc/systemd/system/argocd-port.service
[Unit]
Description=Port forward ArgoCD
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/local/bin/kubectl port-forward svc/argocd-server -n argocd 8080:443
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Systemd-сервіс для port-forward myapp
cat <<EOF > /etc/systemd/system/app-port.service
[Unit]
Description=Port forward myapp-service
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/local/bin/kubectl port-forward svc/myapp-service -n app 8081:80
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable argocd-port.service
systemctl enable app-port.service
systemctl start argocd-port.service
systemctl start app-port.service


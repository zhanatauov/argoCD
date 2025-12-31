Для запуску Github Actions:
1. Створіть репозиторій на докер хаб.
2. Задайте креденшали.
4. Пайплайн автоматично запуститься при змінах репозиторії. 

Для запуску кластеру: 
1. Склонуйте репозиторій на свою локальну машину.
2. Експортуйте свій профалй для роботи з AWS.
3. Виконайте terraform init, plan, apply.
4. Чекайте завершення кластера і в аутпутах отримаєте імя кластеру.

Для роботи з кластреом:
1. Виконайте:
   aws eks update-kubeconfig --name <імя_вашого_кластеру>
2. Деплоїм argocd-application в кластер.
   kubectl apply -f argocd-application.yaml
4. Пісял деплою він розгорне всі необхідні залежності і аплікейш.

   Для перевірки:
   kubectl get ingress -A
   kubectl get svc -n ingress-nginx

   Аплікейш достпуний за адресою:
   <AWS_LB_DNS_NAME>/app

   Atgo достпуний за адресою:
   <AWS_LB_DNS_NAME>/argo
   доступ до UI Argo:
   user - adim
   for password - kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

   Для перевікри:
   В deployment.yaml змінимо image: savanchukpavlo/step_5_backend:latest на image: savanchukpavlo/step_5_backend:test.
   #примітка: імедж з тегом test був попередньо запушений.

   Арго автоматично побачить зміни і передеплоїть наш аплікейшн. 

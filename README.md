# HW26: Kubernetes. Запуск кластера и приложения. Модель безопасности.

- Развернуть локальное окружение для работы сKubernetes;
- Развернуть Kubernetes в GKE;
- Запустить reddit в Kubernetes.

1. Все способы установки kubectl:

```
https://kubernetes.io/docs/tasks/tools/install-kubectl/
```

2. Инструкция по установке Minikube для разных ОС:
```
https://kubernetes.io/docs/tasks/tools/install-minikube/
```

3. Запустим наш Minukube-кластер
```
minikube start
```

4. Запустим наш Minukube-кластер c заданными параметрами конфигурации
```
minikube start --cpus=4 --memory 4096 --disk-size='10000mb'
```

5. Выдать web-странцы с сервисами которые были помечены типом NodePort
```
minikube service ui
```

6. Список сервисов в minikube
```
minikube service list
```

7. Получить список расширений minikube
```
minikube addons list
```

# HW21: Введение в мониторинг. Системы мониторинга.

- Мониторинг Docker контейнеров
- Визуализация метрик
- Сбор метрик работы приложения и бизнес метрик
- Настройка и проверка алертинга
- Много заданий со ⭐ (необязательных)

1. В процессе задания будет создано несколько правил FW для разных сервисов:
```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
gcloud compute firewall-rules create grafana-default --allow tcp:3000
gcloud compute firewall-rules create alertmanager-default --allow tcp:9093
```

2. Создадим Docker хост в GCE и настроим локальное окружение на работу с ним
```
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host

# Настроить докер клиент на удаленный докер демон
eval $(docker-machine env docker-host)

# Переключение на локальный докер
eval $(docker-machine env --unset)
```

3. Для запуска приложений будем как и ранее использовать
```
docker-compose up -d
```

4. Для запуска мониторинга
```
docker-compose -f docker-compose-monitoring.yml up -d
```

5. Добавим информацию о новом сервисе cAdvisor в конфигурацию Prometheus и пересоберем образ Prometheus с обновленной конфигурацией:
```
export USER_NAME=username # где username - ваш логин на Docker Hub
docker build -t $USER_NAME/prometheus .
```

6. Запустим сервисы
```
docker-compose up -d
docker-compose -f docker-compose-monitoring.yml up -d
```

7. Проверка сервисов
```
docker-compose ps
docker-compose -f docker-compose-monitoring.yml ps
```

8. Запустим сервис gragfana (при добавлнении в файл конфигигурации нового сервиса под названием grafana)
```
docker-compose -f docker-compose-monitoring.yml up -d grafana
```

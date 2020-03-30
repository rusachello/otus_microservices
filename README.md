# HW20: Введение в мониторинг. Системы мониторинга.

- Prometheus: запуск, конфигурация, знакомство с Web UI
- Мониторинг состояния микросервисов
- Сбор метрик хоста с использованием экспортера
- Задания со *

1. Создадим правило фаервола для Prometheus и Puma:
```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```

2. Создадим Docker хост в GCE и настроим локальное окружение на работу с ним
```
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host

# configure local env
eval $(docker-machine env docker-host)
```

3. Prometheus будем запускать внутри Docker контейнера. Для начального знакомства воспользуемся готовым образом с DockerHub.
```
$ docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus
```

4. IP адрес созданной VM можно узнать, используя команду:
```
docker-machine ip docker-host
```

5. В директории prometheus собираем Docker образ:
```
$ export USER_NAME=username
$ docker build -t $USER_NAME/prometheus .
```
Где USER_NAME - ВАШ логин от DockerHub.

6. Выполните сборку образов при помощи скриптов docker_build.sh в директории каждого сервиса.
```
/src/ui $ bash docker_build.sh
/src/post-py $ bash docker_build.sh
/src/comment $ bash docker_build.sh
```
Или сразу все из корня репозитория:
```
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```

# HW23: Введение в мониторинг. Системы мониторинга.

- Сбор неструктурированных логов
- Визуализация логов
- Сбор структурированных логов
- Распределенная трасировка

1. Создадим Docker хост в GCE и настроим локальное окружение на работу с ним
```
export GOOGLE_PROJECT=otus-docker

docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    logging


$ eval $(docker-machine env logging)

# узнаем IP адрес
$ docker-machine ip logging
```

2. Собрать docker image для fluentd из директории logging/fluentd
```
docker build -t $USER_NAME/fluentd .
```

3. Правим .env файл и меняем теги нашего приложения на logging, затем запустим сервисы приложения
```
docker-compose up -d
```

4. Команда для просмотра логов post сервиса:
```
docker-compose logs -f post
```

5. Поднимем инфраструктуру централизованной системы логирования и перезапустим сервисы приложения из каталога docker
```
docker-compose -f docker-compose-logging.yml up -d
docker-compose down
docker-compose up -d
```

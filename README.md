# HW17: Docker: сети, docker-compose

### Cоздаем контейнеры из доступных сетевых интерфейсов только loopback

```
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
docker run -d --network none joffotron/docker-net-tools -c 'ping localhost'
```
### Запустим контейнер в сетевом пространстве docker-хоста

```
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
docker run --network host -d nginx
```
### На docker-host машине выполните команду

```
docker-machine ssh docker-host 'sudo ln -s /var/run/docker/netns /var/run/netns'
```
### Просматривать на docker-host существующие в данный момент net-namespaces

```
docker-machine ssh docker-host 'sudo ip netns'
```
### ip netns exec <namespace> <command> - позволит выполнять команды в выбранном namespace

```
docker-machine ssh docker-host 'sudo ip netns exec c9e839714221 ifconfig'
```
### Создадим bridge-сеть в docker (флаг --driver указывать необязательно, т.к. по-умолчанию используется bridge)

```
docker network create reddit --driver bridge
```
### Создадим docker-сети

```
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
```
### Запустим контейнеры

```
docker run -d --network=front_net -p 9292:9292 --name ui rusachello/ui:3.0
docker run -d --network=back_net --name comment rusachello/comment:2.0
docker run -d --network=back_net --name post rusachello/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
```
### Дополнительные сети подключаются командой

```
docker network connect <network> <container>
```
### Просмотр veth-интерфейсов на бриджовом интерфейсе

```
brctl show br-20f5e0dc25aa
```


## Установка docker-compose (2 способа)

```
https://docs.docker.com/compose/install/#install-compose
pip install docker-compose
```

### Запуск контейнеров

```
export USERNAME=<your-login>
docker-compose up -d
docker-compose ps
```

### Запись переменных в файл .env

```
${USERNAME} ${COMMENT_VERSION} ${POST_VERSION} ${UI_VERSION} ${MONGO_VERSION} ${UI_PORT} ${COMPOSE_PROJECT_NAME}
```

## Задание 2
Базовое имя проекта, берется из имени директории в которой запускается docker-compose. Его можно задать прописав в ENV файл переменную COMPOSE_PROJECT_NAME=<name> или передать через консоль при запуске docker-compose с ключом -p <name>.

COMPOSE_PROJECT_NAME=dockermicroservices

## Задание со *
Docker Compose по умолчанию читает два файла: docker-compose.yml и docker-compose.override.yml. В файле docker-compose-override.yml можно хранить переопределения для существующих сервисов или определять новые. Чтобы использовать несколько файлов (или файл переопределения с другим именем), необходимо передать -f в docker-compose up (порядок имеет значение):
$ docker-compose up -f my-override-1.yml my-overide-2.yml

Для того, что бы можно было изменять код приложений и не выполнять сборку образа будем использовать volume и прокинем в контейнер каталог с приложением. Для запуска puma в дебаг режиме с двумя воркерами воспользуемся entrypoint.

Напишем docker-compose.override.yml
```
version: '3.3'
services:
  ui:
    volumes:
      - ui:/app
    entrypoint:
      - puma
      - --debug
      - -w 2
  post:
    volumes:
      - post-py:/app
  comment:
    volumes:
      - comment:/app
    entrypoint:
      - puma
      - --debug
      - -w 2

volumes:
  ui:
  post-py:
  comment:
```
Запустим docker-compose и проверим результат
```
~/otus_microservices/src(docker-4*) » docker-compose up -d
~/otus_microservices/src(docker-4*) » docker-compose ps
            Name                          Command             State           Ports
--------------------------------------------------------------------------------------------
dockermicroservices_comment_1   puma --debug -w 2             Up
dockermicroservices_post_1      python3 post_app.py           Up
dockermicroservices_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
dockermicroservices_ui_1        puma --debug -w 2             Up      0.0.0.0:9292->9292/tcp
```
Подключимся к контейнеру и посмотрим
```
~/otus_microservices/src(docker-4*) » docker ps -a
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                    NAMES
ad424c97177e        mongo:3.2                "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes        27017/tcp                dockermicroservices_post_db_1
211954177d91        rusachello/ui:1.0        "puma --debug '-w 2'"    2 minutes ago       Up 2 minutes        0.0.0.0:9292->9292/tcp   dockermicroservices_ui_1
872b94d0d05a        rusachello/post:1.0      "python3 post_app.py"    2 minutes ago       Up 2 minutes                                 dockermicroservices_post_1
b45ed4c38618        rusachello/comment:1.0   "puma --debug '-w 2'"    2 minutes ago       Up 2 minutes                                 dockermicroservices_comment_1

~/otus_microservices/src(docker-4*) » docker exec -it 211954177d91 /bin/sh
/app # ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.1  0.6  83884 23020 ?        Ss   12:50   0:00 puma 3.12.0 (tcp://0.0.0.0:9292) [app]
root         6  0.3  1.4 139360 56060 ?        Sl   12:50   0:01 puma: cluster worker 0: 1 [app]
root         7  0.3  1.4 139040 56028 ?        Sl   12:50   0:01 puma: cluster worker 1: 1 [app]
root       222  2.6  0.0   1628     4 pts/0    Ss   12:58   0:00 /bin/sh
root       231  0.0  0.0   1616   464 pts/0    R+   12:59   0:00 ps aux
```

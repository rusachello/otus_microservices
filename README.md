# HW16: Docker-образы. Микросервисы
```
git checkout -b docker-3
```
## Прикрутил Dockerfile Linter
https://github.com/hadolint/hadolint
https://hadolint.github.io/hadolint/
```
export GOOGLE_PROJECT=otus-docker
```
```
docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host
```
Переключаю докер-машин на данное окружение:
```
eval $(docker-machine env docker-host)
```
Проверяю, докер хост создан:
```
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://104.155.127.31:2376           v19.03.4

```
## Скачал, распаковал и переименовал репозиторий в src

В файлах Dockerfile содержатся инструкции по созданию образа. С них, набранных заглавными буквами, начинаются строки этого файла. После инструкций идут их аргументы. Инструкции, при сборке образа, обрабатываются сверху вниз.
Слои в итоговом образе создают только инструкции FROM, RUN, COPY, и ADD.

- FROM — задаёт базовый (родительский) образ.

- LABEL — описывает метаданные. Например — сведения о том, кто создал и поддерживает образ.

- ENV — устанавливает постоянные переменные среды.

- RUN — выполняет команду и создаёт слой образа. Используется для установки в контейнер пакетов.

- COPY — копирует в контейнер файлы и папки.

- ADD — копирует файлы и папки в контейнер, может распаковывать локальные .tar-файлы, можно использовать для curl.

- CMD — описывает команду с аргументами, которую нужно выполнить когда контейнер будет запущен. Аргументы могут быть переопределены при запуске контейнера. В файле может присутствовать лишь одна инструкция CMD.

- WORKDIR — задаёт рабочую директорию для следующей инструкции.

- ARG — задаёт переменные для передачи Docker во время сборки образа.

- ENTRYPOINT — предоставляет команду с аргументами для вызова во время выполнения контейнера. Аргументы не переопределяются.

- EXPOSE — указывает на необходимость открыть порт.

- VOLUME — создаёт точку монтирования для работы с постоянным хранилищем.

Компоненты приложения:
- post-py - сервис отвечающий за написание постов:
- Comment - сервис отвечающий за написание комментариев
- UI - веб-интерфейс, работающий с другими сервисами
- База данных MongoDB


## Задание со *:

Запустите контейнеры с другими сетевыми алиасами:
При запуске контейнеров (docker run) задайте им
переменные окружения соответствующие новым сетевым
алиасам, не пересоздавая образ:
```
docker run -d --network=reddit --network-alias=post_db123 --network-alias=comment_db123 mongo:latest

docker run -d --network=reddit --network-alias=post123 \
-e "POST_DATABASE_HOST=post_db123" \
rusachello/post:1.0

docker run -d --network=reddit --network-alias=comment123 \
-e "COMMENT_DATABASE_HOST=comment_db123" \
rusachello/comment:1.0

docker run -d --network=reddit -p 9292:9292 \
-e "POST_SERVICE_HOST=post123" \
-e "COMMENT_SERVICE_HOST=comment123" \
rusachello/ui:1.0
```
Проверьте работоспособность сервиса:
http://<docker-host-ip>:9292/
Работает!

### Задание со *:

Попробуйте собрать образ на основе Alpine Linux. Придумайте еще способы уменьшить размер образа
Можете реализовать как только для UI сервиса, так и для остальных (post, comment)
Все оптимизации проводите в Dockerfile сервиса.
Дополнительные варианты решения уменьшения размера образов можете оформить в виде файла Dockerfile.<цифра> в папке сервиса

Пробовал использовать разные base image'и для сборки образов, но получилось прикрутить только к 2.2-alpine и alpine3.10 (в прод пошла alpine3.10, соответсвенно rusachello/ui:3.0 - для ui, rusachello/comment:2.0 - для comment, rusachello/post:1.0 - для post)

```
ruby                  slim                149MB
rusachello/ui         1.0                 149MB

ruby                  2.2-alpine          107MB
rusachello/ui         2.0                 160MB

ruby                  alpine3.10          52.9MB
rusachello/ui         3.0                 103MB

andrius/alpine-ruby   latest              26.6MB
rusachello/ui         4.0                 26.7MB
```

## Финальная проверка на чистой машине:
- Готовим имаджи
```
docker build -f=Dockerfile-prod -t rusachello/ui:3.0 ./
docker build -f=Dockerfile-prod -t rusachello/comment:2.0 ./
docker build -f=Dockerfile-prod -t rusachello/post:1.0 ./
```

- Создаем сеть и volume
```
docker network create reddit
docker volume create reddit_db
```

- Запускаем контейнеры
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post rusachello/post:1.0
docker run -d --network=reddit --network-alias=comment rusachello/comment:2.0
docker run -d --network=reddit -p 9292:9292 rusachello/ui:3.0
```

ЕСЛИ вдруг играл на своей машине, то:
```
docker kill $(docker ps -q)
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
# волиумы посмотрим:
docker volume ls
# тож можно поубивать
docker volume rm $(docker volume ls -f dangling=true -q)
```

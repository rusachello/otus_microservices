# HW19: Устройство Gitlab CI. Построение процесса непрерывной поставки

- Подготовить инсталляцию Gitlab CI
- Подготовить репозиторий с кодом приложения
- Описать для приложения этапы пайплайна
- Определить окружения

1. Cоздаем вм в Google Cloud с помощью terraform и разрешаем подключение по HTTP/HTTPS
2. Установка docker engine с помощью ansible-playbook (playbooks/docker-install.yml)

```
- hosts: all
  become: true
  tasks:
  - name: Add Docker GPG key
    apt_key: url=https://download.docker.com/linux/ubuntu/gpg

  - name: Add Docker APT repository
    apt_repository:
      repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ansible_distribution_release}} stable

  - name: Install list of packages
    apt:
      name: ['apt-transport-https','ca-certificates','curl','software-properties-common','docker-ce']
      state: present
      update_cache: yes
```
```
ansible-playbook ./playbooks/docker-install.yml
```

3. Подготовка окружения на новом сервере через ansible-playbook (playbooks/prepare-env.yml)

```
- hosts: all
  become: true
  tasks:

  - name: Create directories
    file:
      path: "{{ item }}"
      state: directory
      recurse: yes
    with_items:
      - '/srv/gitlab/config'
      - '/srv/gitlab/data'
      - '/srv/gitlab/logs'

  - name: Сreate file docker-compose.yml
    copy:
      src: '~/otus_microservices/gitlab-ci/docker-compose.yml'
      dest: '/srv/gitlab/docker-compose.yml'
```

4. Запускаем Gitlab CI

```
docker-compose up -d (/srv/gitlab)
```

5. Создадим группу
6. Создадим проект
7. Добавляем remote в ```<username>_microservices```

```
git checkout -b gitlab-ci-1
git remote add gitlab http://<your-vm-ip>/homework/example.git
git push gitlab gitlab-ci-1
```

8. Определение CI/CD Pipeline для проекта. (добавить файл .gitlab-ci.yml в репозиторий)

```
stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  script:
    - echo 'Testing 1'

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
    - echo 'Deploy'
```

9. На сервере, где работает Gitlab CI запускаем runner

```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

10. Регистируем Runner

```
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
```

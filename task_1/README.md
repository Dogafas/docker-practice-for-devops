# Docker Practice — Task 1 (Автоматизированный стенд с Nginx (ingress), HAProxy (reverse‑proxy), Python FastAPI (web) и MySQL.)

  

**В проекте демонстрируется:**

 - работу нескольких прокси‑уровней
 - статическую маршрутизацию через HAProxy
 - динамическое создание Docker‑сети
 - автоматическое назначение IP для backend
 - автоматический запуск всех сервисов
 - тестовый запрос после старта
 

**Архитектура**

    Client → Nginx (host mode) → HAProxy → Web (FastAPI) → MySQL

**Компоненты:**

|Сервис | Назначение |
|-----------------|--|
|      ingress-proxy           | Принимает HTTP‑запросы на localhost:8090 |
| reverse-proxy | HAProxy, маршрутизирует запросы на web|
|web FastAPI‑приложение|mysql База данных MySQL 8.0|
| task_1_app_net | Внешняя Docker‑сеть с фиксированным IP для web |


**Быстрый старт**

Проект запускается одной командой:

    ./run.sh

**Скрипт сделает автоматически следующее:**
1. Проверит существование сети task_1_app_net
2. Создаст её, если нужно (подберёт свободную подсеть)
3. С генерирует compose.generated.yaml с корректным IP
4. Соберет Python‑образ
5. Запустит все контейнеры
6. Сделает тестовый HTTP‑запрос
  
**Как работает автоматическое назначение IP**

HAProxy требует фиксированный IP backend:

    server web 172.20.0.5:5000

Однако на разных компьютерах подсеть 172.20.0.0/24 может быть занята. Поэтому:

 - run.sh ищет свободную подсеть
 - создаёт сеть task_1_app_net
 - вычисляет IP .5 внутри выбранной подсети
 - патчит compose.yaml → создаёт compose.generated.yaml
 - запускает Docker Compose с этим файлом

Таким образом:

 - web всегда получает IP .5
 - HAProxy всегда работает
 
**Переменные окружения (.env)**

> MYSQL_ROOT_PASSWORD=YtReWq4321
> MYSQL_DATABASE=virtd
> MYSQL_USER=app
> MYSQL_PASSWORD=QwErTy1234
> DB_HOST=mysql
> DB_USER=app
> DB_PASSWORD=QwErTy1234
> DB_NAME=virtd

Запуск вручную (если нужно)

**Создать сеть:**

    docker network create --subnet 172.20.0.0/24 task_1_app_net

**Запустить:**

    docker compose -f compose.generated.yaml up -d --build

**Остановить:**

  

    docker compose -f compose.generated.yaml down --remove-orphans

**Проверка работы**

После запуска:

    curl http://localhost:8090

Ожидаемый ответ:
  
    "TIME: 2025-12-18 04:53:27, IP: 127.0.0.1"

**Healthchecks**

 - MySQL имеет встроенный healthcheck
 - web стартует с задержкой, чтобы HAProxy не ловил 503  
 - HAProxy автоматически определяет UP/DOWN backend

**Используемые технологии:**
 - Docker
 - Docker Compose
 - Python FastAPI
 - MySQL 8.0
 - HAProxy
 - Nginx
 - Bash automation

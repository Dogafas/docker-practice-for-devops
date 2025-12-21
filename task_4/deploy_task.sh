#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Dogafas/docker-practice-for-devops.git"
BASE_DIR="/opt"
PROJECT_ROOT="$BASE_DIR/docker-practice-for-devops"
PROJECT_DIR="$PROJECT_ROOT/task_3"
ENV_FILE="$PROJECT_DIR/.env"
COMPOSE_FILE="$PROJECT_DIR/compose.yaml"

echo "=== Deploy script started ==="

echo
echo "1. Проверка существования каталога проекта..."
if [ ! -d "$PROJECT_ROOT" ]; then
    echo "Каталог отсутствует. Клонирую репозиторий..."
    sudo git clone "$REPO_URL" "$PROJECT_ROOT"
else
    echo "Каталог существует. Обновляю код через git pull..."
    cd "$PROJECT_ROOT"
    sudo git reset --hard HEAD
    sudo git pull --rebase
fi

echo
echo "2. Проверка .env..."
if [ ! -f "$ENV_FILE" ]; then
    echo "Файл .env отсутствует. Создайте его вручную:"
    echo "  sudo nano $ENV_FILE"
    echo
    echo "Пример содержимого:"
    echo "MYSQL_ROOT_PASSWORD=YtReWq4321"
    echo "MYSQL_DATABASE=virtd"
    echo "MYSQL_USER=app"
    echo "MYSQL_PASSWORD=QwErTy1234"
    echo
    echo "DB_HOST=db"
    echo "DB_USER=app"
    echo "DB_PASSWORD=QwErTy1234"
    echo "DB_NAME=virtd"
    echo
    echo "После создания файла запустите скрипт снова."
    exit 1
else
    echo ".env найден."
fi

echo
echo "3. Проверка compose.yaml..."
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "compose.yaml отсутствует в $PROJECT_DIR"
    exit 1
else
    echo "compose.yaml найден."
fi

echo
echo "4. Запуск Docker Compose..."
cd "$PROJECT_DIR"

# ВАЖНО: НЕ удаляем volumes, чтобы база не терялась
sudo docker compose down || true
sudo docker compose up -d --build

echo
echo "5. Проверка контейнеров..."
sudo docker compose ps

echo
echo "=== Deploy completed ==="

#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Dogafas/docker-practice-for-devops.git"
BASE_DIR="/opt"
PROJECT_DIR="$BASE_DIR/docker-practice-for-devops/task_3"
ENV_FILE="$PROJECT_DIR/.env"
COMPOSE_FILE="$PROJECT_DIR/compose.yaml"

echo "=== Deploy script started ==="

echo "1. Клонирование репозитория..."
if [ -d "$BASE_DIR/docker-practice-for-devops" ]; then
    echo "Каталог уже существует, обновляю..."
    sudo rm -rf "$BASE_DIR/docker-practice-for-devops"
fi

sudo git clone "$REPO_URL" "$BASE_DIR/docker-practice-for-devops"
echo "Репозиторий скачан."

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
sudo docker compose down -v || true
sudo docker compose up -d --build

echo
echo "5. Проверка контейнеров..."
sudo docker compose ps

echo
echo "=== Deploy completed ==="

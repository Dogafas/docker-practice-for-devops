#!/usr/bin/env bash
set -e

echo "[1/4] Сборка Python-образа..."
docker build -f Dockerfile.python -t task1-python .

echo "[2/4] Запуск docker compose..."
docker compose up -d --build

echo "[3/4] Ожидание запуска сервисов..."
sleep 3

echo "[4/4] Тестовый запрос:"
curl -v http://localhost:8090 || true

echo "Готово."

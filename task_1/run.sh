#!/usr/bin/env bash
set -e

NET_NAME="task_1_app_net"

# Список подсетей, которые будем пробовать
SUBNETS=(
  "172.20.0.0/24"
  "172.30.0.0/24"
  "172.31.0.0/24"
  "10.10.0.0/24"
  "192.168.250.0/24"
)

echo "[0/5] Проверка существования сети $NET_NAME..."

if docker network inspect "$NET_NAME" >/dev/null 2>&1; then
    echo "  → Сеть уже существует."
    # Определяем её подсеть
    CURRENT_SUBNET=$(docker network inspect "$NET_NAME" -f '{{(index .IPAM.Config 0).Subnet}}')
    echo "  → Используем существующую подсеть: $CURRENT_SUBNET"
else
    echo "  → Сеть не найдена. Ищу свободную подсеть..."

    for SUBNET in "${SUBNETS[@]}"; do
        if docker network create --driver bridge --subnet "$SUBNET" "$NET_NAME" >/dev/null 2>&1; then
            echo "  → Создана сеть $NET_NAME с подсетью $SUBNET"
            CURRENT_SUBNET="$SUBNET"
            break
        else
            echo "  → Подсеть $SUBNET занята. Пробую следующую..."
        fi
    done

    if [ -z "$CURRENT_SUBNET" ]; then
        echo "Не удалось создать сеть ни с одной подсетью."
        exit 1
    fi
fi

# Вычисляем IP .5 внутри выбранной подсети
BASE=$(echo "$CURRENT_SUBNET" | cut -d'.' -f1-3)
WEB_IP="$BASE.5"

echo "[1/5] Выбран IP для web: $WEB_IP"

echo "[2/5] Патчинг compose.yaml под выбранную подсеть..."

# Создаём временный compose-файл
cp compose.yaml compose.generated.yaml

# Заменяем IP web
sed -i "s/ipv4_address:.*/ipv4_address: $WEB_IP/" compose.generated.yaml

echo "  → compose.generated.yaml готов."

echo "[3/5] Сборка Python-образа..."
docker build -f Dockerfile.python -t task1-python .

echo "[4/5] Запуск docker compose..."
docker compose -f compose.generated.yaml up -d --build

echo "[5/5] Тестовый запрос:"
sleep 3
curl -v http://localhost:8090 || true

echo "Готово."

#!/bin/sh

while ! grep -q "1" /shared/initializer; do
    echo "[*] Waiting for initializer..."
    sleep 3
done

cd /app

script/cs manager
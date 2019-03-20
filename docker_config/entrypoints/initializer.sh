#!/bin/sh

if grep -q "1" /shared/initializer; then
    echo "[+] Already intialized, exiting!"
    exit 0
fi

echo "[*] Waiting 10 secs for postgres to start"
sleep 10

cd /app

echo "[*] Resetting database"
script/cs reset_db

echo "[*] Initializing database"
script/cs init_db

echo "[+] Done!"
echo "1" > /shared/initializer
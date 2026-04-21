#!/bin/bash

MAC_ADDR="CE:A8:DD:E4:97:D0"

echo "1. Asegurando antena Bluetooth..."
rfkill unblock bluetooth

echo "2. Intentando conectar al MX Master ($MAC_ADDR)..."
# Hemos quitado el > /dev/null 2>&1 para ver qué dice el ordenador
if bluetoothctl connect "$MAC_ADDR"; then
    echo "✅ CONECTADO CON ÉXITO"
    notify-send -u normal "🖱️ MX Master" "✅ Connected!"
else
    echo "❌ FALLO AL CONECTAR"
    notify-send -u normal "🖱️ Error" "Unable to connect.\nAre you setting the connection nº3?"
fi

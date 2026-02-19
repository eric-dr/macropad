#!/bin/bash

# --- CONFIGURACIÓN ---
# Convertimos la MAC a mayúsculas por si acaso, aunque suele dar igual
MAC_ADDR="CE:A8:DD:E4:97:CF"

# 1. Notificación discreta de inicio
notify-send -u low "🖱️ MX Master" "Connecting..."

# 2. Asegurar que el Bluetooth está activo
rfkill unblock bluetooth

# 3. Intentar conectar
# Si el comando devuelve 0 (éxito), entra en el 'then'.
# Si devuelve error (1), entra en el 'else'.
if bluetoothctl connect "$MAC_ADDR"; then
    notify-send -u normal "🖱️ MX Master" "Connected!"
else
    # El mensaje específico que pediste para recordarte mirar debajo del ratón
    notify-send -u critical "🖱️ Error" "Are you setting the connection nº3?"
fi

#!/bin/bash

# 1. Detectar el micrófono predeterminado actual (AirPods, PC, etc.)
SOURCE=$(pactl get-default-source)

# 2. Comprobar si está muteado actualmente
IS_MUTED=$(pactl get-source-mute "$SOURCE" | grep -o "yes")

if [ "$IS_MUTED" = "yes" ]; then
    # --- ABRIR MICRO (Vas a hablar) ---
    # Seteamos el volumen al 30% como has pedido
    pactl set-source-volume "$SOURCE" 30%
    pactl set-source-mute "$SOURCE" 0
    notify-send -u normal -t 1500 "🎙️ MICRO" "🟢 ACTIVO (Volumen 30%)"
else
    # --- CERRAR MICRO (Silencio total) ---
    # Muteamos y bajamos volumen a cero para seguridad total
    pactl set-source-mute "$SOURCE" 1
    pactl set-source-volume "$SOURCE" 0%
    notify-send -u normal -t 1500 "🎙️ MICRO" "🔴 SILENCIADO"
fi
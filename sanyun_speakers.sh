#!/bin/bash

# --- CONFIGURACIÓN ---
# Buscamos algo que contenga "USB2.0" explícitamente.
# Si en tu lista anterior sale escrito distinto (ej: "USB_2.0"), cámbialo aquí.
SINK_KEYWORD="USB2.0"

# 1. BUSCAR NOMBRE TÉCNICO
# grep -i ignora mayúsculas/minúsculas
NEW_SINK=$(pactl list sinks short | grep -i "$SINK_KEYWORD" | awk '{print $2}' | head -n 1)

# VERIFICACIÓN DE SEGURIDAD
# Si por casualidad ha cogido el US-2x2 (porque tiene USB2.0 en el nombre),
# podemos excluirlo explícitamente descomentando la siguiente línea:
# NEW_SINK=$(pactl list sinks short | grep -i "$SINK_KEYWORD" | grep -v "US-2x2" | awk '{print $2}' | head -n 1)

if [ -n "$NEW_SINK" ]; then
    # 2. ESTABLECER COMO PREDETERMINADO
    pactl set-default-sink "$NEW_SINK"
    
    # 3. MOVER AUDIO ACTIVO (Spotify, Chrome, Teams...)
    pactl list short sink-inputs | awk '{print $1}' | while read stream_id; do
        pactl move-sink-input "$stream_id" "$NEW_SINK"
    done
    
    # Desmutear
    pactl set-sink-mute "$NEW_SINK" 0
    
    notify-send -u normal "🔊 Altavoces USB" "✅ Conectado a: USB 2.0 Device"
else
    notify-send -u critical "🔊 Error USB" "❌ No se encuentra 'USB2.0 Device'.\nRevisa el nombre con 'pactl list sinks short'"
fi
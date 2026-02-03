#!/bin/bash

# --- CONFIGURACIÓN ---
# Buscamos dispositivos que contengan "pci" (suele ser la tarjeta interna)
# y que sean analógicos (evitamos HDMI si no es lo que quieres).
SINK_KEYWORD="pci"    # Para los altavoces
SOURCE_KEYWORD="pci"  # Para el micro interno

# 1. BUSCAR LOS NOMBRES TÉCNICOS
# Buscamos el primer dispositivo que coincida con "pci" y "analog"
NEW_SINK=$(pactl list sinks short | grep "$SINK_KEYWORD" | grep "analog" | awk '{print $2}' | head -n 1)
NEW_SOURCE=$(pactl list sources short | grep "$SOURCE_KEYWORD" | grep "analog" | awk '{print $2}' | head -n 1)

# 2. CONFIGURAR SALIDA (ALTAVOCES)
if [ -n "$NEW_SINK" ]; then
    # Establecer como predeterminado
    pactl set-default-sink "$NEW_SINK"
    
    # MOVER AUDIO ACTIVO (Spotify, etc)
    pactl list short sink-inputs | awk '{print $1}' | while read stream_id; do
        pactl move-sink-input "$stream_id" "$NEW_SINK"
    done
    
    # Asegurar volumen al 50% (para no asustarse)
    pactl set-sink-mute "$NEW_SINK" 0
    pactl set-sink-volume "$NEW_SINK" 50%
    
    MSG_OUT="🔊 Altavoces PC"
else
    MSG_OUT="❌ Altavoces no encontrados"
fi

# 3. CONFIGURAR ENTRADA (MICRO INTERNO)
if [ -n "$NEW_SOURCE" ]; then
    pactl set-default-source "$NEW_SOURCE"
    
    # MOVER APPS DE GRABACIÓN (Teams, etc)
    pactl list short source-outputs | awk '{print $1}' | while read stream_id; do
        pactl move-source-output "$stream_id" "$NEW_SOURCE"
    done
    
    pactl set-source-mute "$NEW_SOURCE" 0
    MSG_IN="🎙️ Micro Interno"
else
    MSG_IN="❌ Micro no encontrado"
fi

# 4. NOTIFICACIÓN
notify-send -u normal "💻 Modo PC" "$MSG_OUT\n$MSG_IN"
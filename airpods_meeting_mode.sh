#!/bin/bash

MAC="18:3F:70:BB:2A:87"
MAC_SNAKE="${MAC//:/_}"
CARD="bluez_card.$MAC_SNAKE"

notify-send -u normal "AirPods" "Meeting Mode: Detecting Profiles..."

# 1. Asegurar Conexión
if ! bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
    bluetoothctl connect "$MAC" > /dev/null 2>&1
    sleep 3
fi

# 2. BUSCAR PERFIL DE VOZ DISPONIBLE
# Le preguntamos a la tarjeta qué perfiles tiene que tengan la palabra 'headset'
# Esto evita el error "No such entity"
BEST_PROFILE=$(pactl list cards | grep -A 50 "$CARD" | grep -oP 'headset-head-unit[^\s:]*' | head -n 1)

if [ -z "$BEST_PROFILE" ]; then
    # Intento 2 con nombre genérico
    BEST_PROFILE=$(pactl list cards | grep -A 50 "$CARD" | grep -oP 'handsfree[^\s:]*' | head -n 1)
fi

if [ -z "$BEST_PROFILE" ]; then
    notify-send -u normal "AirPods" "❌ Error: Microphone profile NOT available in system."
    pactl set-card-profile "$CARD" a2dp-sink # Volver a música para no dejarlo en 'off'
    exit 1
fi

echo "Perfil detectado: $BEST_PROFILE"

# 3. CAMBIO DE PERFIL
pactl set-card-profile "$CARD" off
sleep 1
pactl set-card-profile "$CARD" "$BEST_PROFILE"

# 4. BUSCAR SINK Y SOURCE (Polling)
SINK_NAME=""
SOURCE_NAME=""
for i in {1..15}; do
    SINK_NAME=$(pactl list sinks short | grep -i "$MAC_SNAKE" | awk '{print $2}' | head -n 1)
    SOURCE_NAME=$(pactl list sources short | grep -i "$MAC_SNAKE" | grep "bluez_input" | awk '{print $2}' | head -n 1)
    if [ -n "$SOURCE_NAME" ]; then break; fi
    sleep 0.3
done

# 5. CONFIGURACIÓN FINAL
if [ -n "$SOURCE_NAME" ]; then
    pactl set-default-sink "$SINK_NAME"
    pactl set-default-source "$SOURCE_NAME"
    pactl set-source-mute "$SOURCE_NAME" 1
    pactl set-source-volume "$SOURCE_NAME" 0%
    
    # Mover apps activas
    pactl list short sink-inputs | awk '{print $1}' | while read id; do pactl move-sink-input "$id" "$SINK_NAME" 2>/dev/null; done
    pactl list short source-outputs | awk '{print $1}' | while read id; do pactl move-source-output "$id" "$SOURCE_NAME" 2>/dev/null; done
    
    notify-send -u normal "AirPods" "✅ Meeting Mode Active ($BEST_PROFILE)"
else
    notify-send -u normal "AirPods" "❌ Error: Microphone not found after switch."
fi
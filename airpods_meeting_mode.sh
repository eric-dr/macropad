#!/bin/bash

MAC="18:3F:70:BB:2A:87"
# Formateamos la MAC para que coincida con lo que busca PipeWire (puntos o guiones)
MAC_CLEAN=$(echo $MAC | tr ':' '.')
MAC_SNAKE=$(echo $MAC | tr ':' '_')

notify-send -u normal "AirPods" "Meeting Mode: Connecting..."

# 1. Asegurar Conexión Bluetooth
if ! bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
    bluetoothctl connect "$MAC" > /dev/null 2>&1
    sleep 3
fi

# 2. BUCLE DE ESPERA PARA LA TARJETA (CARD)
# Esperamos hasta 10 segundos a que la tarjeta aparezca en PipeWire
CARD_ID=""
for i in {1..20}; do
    CARD_ID=$(pactl list cards short | grep -iE "$MAC_CLEAN|$MAC_SNAKE" | awk '{print $1}')
    if [ -n "$CARD_ID" ]; then break; fi
    sleep 0.5
done

if [ -z "$CARD_ID" ]; then
    notify-send -u normal "AirPods" "❌ Error: Audio Card not found"
    exit 1
fi

# 3. CAMBIO DE PERFIL
# Primero forzamos OFF para limpiar el canal
pactl set-card-profile "$CARD_ID" off > /dev/null 2>&1
sleep 0.5

# Intentamos activar el micrófono
if pactl set-card-profile "$CARD_ID" headset-head-unit-msbc 2>/dev/null; then
    MODE="HD Voice"
elif pactl set-card-profile "$CARD_ID" headset-head-unit 2>/dev/null; then
    MODE="Standard"
else
    notify-send -u normal "AirPods" "❌ Error: Microphone profile failed"
    exit 1
fi

# 4. BÚSQUEDA DE SINK (Audio) Y SOURCE (Micro)
SINK_NAME=""
SOURCE_NAME=""
for i in {1..15}; do
    SINK_NAME=$(pactl list sinks short | grep -i "$MAC_SNAKE" | awk '{print $2}' | head -n 1)
    SOURCE_NAME=$(pactl list sources short | grep "bluez_input" | grep -i "$MAC_SNAKE" | awk '{print $2}' | head -n 1)
    if [ -n "$SOURCE_NAME" ]; then break; fi
    sleep 0.3
done

# 5. CONFIGURACIÓN FINAL
if [ -n "$SOURCE_NAME" ]; then
    pactl set-default-sink "$SINK_NAME"
    pactl set-default-source "$SOURCE_NAME"
    
    # SILENCIO INICIAL (Seguridad)
    pactl set-source-mute "$SOURCE_NAME" 1
    pactl set-source-volume "$SOURCE_NAME" 0%
    
    # Mover llamadas de Teams
    pactl list short source-outputs | awk '{print $1}' | while read id; do
        pactl move-source-output "$id" "$SOURCE_NAME" 2>/dev/null
    done
    
    notify-send -u normal "AirPods" "✅ Meeting Ready ($MODE)\nMic Silenced"
else
    notify-send -u normal "AirPods" "❌ Mic not found after profile switch"
fi
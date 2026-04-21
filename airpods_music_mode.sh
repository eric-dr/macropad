#!/bin/bash

MAC="18:3F:70:BB:2A:87"
CARD="bluez_card.18_3F_70_BB_2A_87"

notify-send -u normal "AirPods" "Setting Music Mode"

# 1. Conexión forzada con reintento rápido (máximo 5 segundos)
if ! bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
    for i in {1..10}; do
        bluetoothctl connect "$MAC" > /dev/null 2>&1
        sleep 0.5
        if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then break; fi
    done
fi

# 2. Reset agresivo del perfil para liberar el micro (imprescindible en 24.04)
pactl set-card-profile "$CARD" off 2>/dev/null
pactl set-card-profile "$CARD" a2dp-sink-sbc 2>/dev/null || pactl set-card-profile "$CARD" a2dp-sink 2>/dev/null

# 3. Bucle de espera inteligente para el dispositivo de salida (Sink)
SINK_NAME=""
for i in {1..20}; do
    SINK_NAME=$(pactl list sinks short | grep -i "18_3F_70_BB_2A_87" | awk '{print $2}' | head -n 1)
    if [ -n "$SINK_NAME" ]; then break; fi
    sleep 0.1
done

# 4. Configuración final
if [ -n "$SINK_NAME" ]; then
    pactl set-default-sink "$SINK_NAME"
    # Mover audio activo
    pactl list short sink-inputs | awk '{print $1}' | while read id; do
        pactl move-sink-input "$id" "$SINK_NAME" 2>/dev/null
    done
    pactl set-sink-volume "$SINK_NAME" 60%
    notify-send -u normal "AirPods" "Music Mode Active"
else
    notify-send -u normal "AirPods" "Error: Sink not found"
fi

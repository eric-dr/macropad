#!/bin/bash

MAC="18:3F:70:BB:2A:87"
CARD="bluez_card.18_3F_70_BB_2A_87"

notify-send -u normal "AirPods" "Setting Meeting Mode (Starting Silenced)"

# 1. Conexión forzada
if ! bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
    for i in {1..10}; do
        bluetoothctl connect "$MAC" > /dev/null 2>&1
        sleep 0.5
        if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then break; fi
    done
fi

# 2. Estabilización y cambio a Micrófono
pactl set-card-profile "$CARD" a2dp-sink-sbc 2>/dev/null
pactl set-card-profile "$CARD" headset-head-unit-msbc 2>/dev/null || pactl set-card-profile "$CARD" handsfree_head_unit 2>/dev/null

# 3. Bucle de espera inteligente para Salida (Sink) y Entrada (Source)
SINK_NAME=""
SOURCE_NAME=""
for i in {1..20}; do
    SINK_NAME=$(pactl list sinks short | grep -i "18_3F_70_BB_2A_87" | awk '{print $2}' | head -n 1)
    SOURCE_NAME=$(pactl list sources short | grep -i "18_3F_70_BB_2A_87" | grep -v "monitor" | awk '{print $2}' | head -n 1)
    if [ -n "$SINK_NAME" ] && [ -n "$SOURCE_NAME" ]; then break; fi
    sleep 0.1
done

# 4. Configuración final con BLINDAJE DE SILENCIO
if [ -n "$SOURCE_NAME" ]; then
    pactl set-default-sink "$SINK_NAME"
    pactl set-default-source "$SOURCE_NAME"
    
    # --- BLOQUEO DE SEGURIDAD INICIAL ---
    pactl set-source-mute "$SOURCE_NAME" 1    # Activar Mute
    pactl set-source-volume "$SOURCE_NAME" 0% # Bajar volumen a cero
    # ------------------------------------
    
    # Mover audio de salida y de entrada (llamadas activas)
    pactl list short sink-inputs | awk '{print $1}' | while read id; do
        pactl move-sink-input "$id" "$SINK_NAME" 2>/dev/null
    done
    pactl list short source-outputs | awk '{print $1}' | while read id; do
        pactl move-source-output "$id" "$SOURCE_NAME" 2>/dev/null
    done
    
    notify-send -u normal "AirPods" "Meeting Mode Active - MIC PROTECTED"
else
    notify-send -u normal "AirPods" "Error: Microphone not found"
fi
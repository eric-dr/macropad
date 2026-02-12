#!/bin/bash

# --- CONFIGURACIÓN ---
MAC_ADDR="18:3F:70:BB:2A:87"
PA_CARD="bluez_card.18_3F_70_BB_2A_87"

# 1. Notificación de inicio
notify-send -u normal "Airpods meeting mode" "Working..."


# 2. CONEXIÓN BASE
rfkill unblock bluetooth
bluetoothctl connect "$MAC_ADDR"

# Esperamos a que el sistema los reconozca
sleep 4

# --- FASE 1: FORZAR MODO MÚSICA (RESET) ---
# Esto limpia cualquier estado corrupto anterior.
# Ponemos perfil de alta fidelidad primero.
pactl set-card-profile "$PA_CARD" a2dp_sink
# Esperamos 2 segundos para que se asiente
sleep 2

# --- FASE 2: CAMBIO A MODO REUNIÓN ---
# Ahora que sabemos que están bien conectados, cambiamos al perfil de voz.
pactl set-card-profile "$PA_CARD" handsfree_head_unit

# Esperamos 2 segundos a que el micro aparezca en el sistema
sleep 2

# --- FASE 3: CONFIGURACIÓN DE AUDIO (Forzar todo) ---

# Buscamos los nombres técnicos del nuevo perfil HFP
NEW_SINK=$(pactl list sinks short | grep "18_3F_70_BB_2A_87" | awk '{print $2}' | head -n 1)
NEW_SOURCE=$(pactl list sources short | grep "18_3F_70_BB_2A_87" | grep -v "monitor" | awk '{print $2}' | head -n 1)

# CONFIGURAR SALIDA (LO QUE ESCUCHAS)
if [ -n "$NEW_SINK" ]; then
    # Poner como predeterminado
    pactl set-default-sink "$NEW_SINK"
    
    # MOVER AUDIO EXISTENTE (Spotify, Chrome, Teams...) a los cascos
    pactl list short sink-inputs | awk '{print $1}' | while read stream_id; do
        pactl move-sink-input "$stream_id" "$NEW_SINK"
    done
fi

# CONFIGURAR ENTRADA (MICROFONO)
if [ -n "$NEW_SOURCE" ]; then
    # Poner como predeterminado
    pactl set-default-source "$NEW_SOURCE"
    
    # MOVER GRABACIONES EXISTENTES (Si Teams ya estaba abierto)
    pactl list short source-outputs | awk '{print $1}' | while read stream_id; do
        pactl move-source-output "$stream_id" "$NEW_SOURCE"
    done
    
    # SUBIR VOLUMEN DEL MICRO AL 100% (Importante para clones)
    pactl set-source-volume "$NEW_SOURCE" 100%
    
    notify-send -u normal "Airpods Meeting Mode" "Connected"
else
    # Si falla, avisamos
    notify-send -u normal "Airpods Meeting Mode" "Airpods microphone not found. Please check connection."
fi

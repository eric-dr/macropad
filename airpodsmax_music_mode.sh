#!/bin/bash

# --- CONFIGURACIÓN ---
# Dirección MAC detectada (0A:E1:68:C3:3E:8A)
MAC_ADDR="0A:E1:68:C3:3E:8A"

# Nombre de la tarjeta para PulseAudio (MAC con barras bajas en vez de dos puntos)
PA_CARD="bluez_card.0A_E1_68_C3_3E_8A"

# 1. Notificar usuario
notify-send -u low "🎧 Music Mode" "Conectando..."

# 2. Desbloquear y Conectar
rfkill unblock bluetooth

# Intentamos confiar primero por si acaso
bluetoothctl trust "$MAC_ADDR" > /dev/null 2>&1

if bluetoothctl connect "$MAC_ADDR"; then
    
    # Esperamos a que Ubuntu registre el dispositivo de audio
    sleep 4

    # 3. Forzar Perfil de Alta Fidelidad (A2DP)
    # Probamos las variantes por si tu Ubuntu usa AAC o SBC
    if pactl set-card-profile "$PA_CARD" a2dp_sink; then
        STATUS="Perfil: A2DP (Estándar)"
    elif pactl set-card-profile "$PA_CARD" a2dp_sink_aac; then
        STATUS="Perfil: A2DP (AAC)"
    elif pactl set-card-profile "$PA_CARD" a2dp_sink_sbc; then
        STATUS="Perfil: A2DP (SBC)"
    else
        STATUS="(No se pudo forzar A2DP)"
    fi

    # 4. Establecer como Salida Predeterminada y Mover Audio
    SINK_NAME=$(pactl list sinks short | grep "$PA_CARD" | awk '{print $2}' | head -n 1)
    
    if [ -n "$SINK_NAME" ]; then
        # Poner como default
        pactl set-default-sink "$SINK_NAME"
        
        # Mover lo que esté sonando ahora mismo (Spotify, Chrome...) a los cascos
        pactl list short sink-inputs | awk '{print $1}' | while read stream_id; do
            pactl move-sink-input "$stream_id" "$SINK_NAME"
        done
    fi

    notify-send -u normal "🎧 Music Mode" "Airpods MAx Connected: $MAC_ADDR\n$STATUS"

else
    notify-send -u critical "🎧 Music Mode" "Unable to connect Airpods Max"
fi

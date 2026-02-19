#!/bin/bash

# --- CONFIGURACIÓN ---
MAC_ADDR="0A:E1:68:C3:3E:8A"
PA_CARD="bluez_card.0A_E1_68_C3_3E_8A"

notify-send -u normal "AirpodsMax" "Connecting Music Mode..."

# 1. LIMPIEZA PREVIA (CRUCIAL PARA EVITAR BUSY)
rfkill unblock bluetooth
# Forzamos parada de escaneo (silenciando errores)
bluetoothctl scan off > /dev/null 2>&1
# Desconectamos por si se quedó a medias
bluetoothctl disconnect "$MAC_ADDR" > /dev/null 2>&1
# Aseguramos confianza
bluetoothctl trust "$MAC_ADDR" > /dev/null 2>&1

# 2. BUCLE DE CONEXIÓN (INTENTAR 3 VECES)
connected=false
for i in {1..3}; do
    echo "Intento $i..."
    if bluetoothctl connect "$MAC_ADDR"; then
        connected=true
        break
    fi
    # Si falla, esperamos un poco antes de reintentar
    sleep 2
done

# 3. SI SE CONECTÓ, CONFIGURAMOS AUDIO
if [ "$connected" = true ]; then
    
    # Esperamos a que PulseAudio reconozca la tarjeta
    sleep 5

    # Forzar Perfil A2DP (Probando variantes)
    if pactl set-card-profile "$PA_CARD" a2dp_sink; then
        STATUS="A2DP (Std)"
    elif pactl set-card-profile "$PA_CARD" a2dp_sink_aac; then
        STATUS="A2DP (AAC)"
    elif pactl set-card-profile "$PA_CARD" a2dp_sink_sbc; then
        STATUS="A2DP (SBC)"
    else
        STATUS="(Audio Std)"
    fi

    # Buscar el nombre del Sink
    SINK_NAME=$(pactl list sinks short | grep "0A_E1_68_C3_3E_8A" | awk '{print $2}' | head -n 1)
    
    if [ -n "$SINK_NAME" ]; then
        # Poner como default
        pactl set-default-sink "$SINK_NAME"
        
        # Mover audio activo
        pactl list short sink-inputs | awk '{print $1}' | while read stream_id; do
            pactl move-sink-input "$stream_id" "$SINK_NAME"
        done
        notify-send -u normal "AirpodsMax" "✅ Connected ($STATUS)."
    else
        notify-send -u critical "AirpodsMax" "⚠️ Connected but Audio sink not found."
    fi

else
    # Si fallaron los 3 intentos
    notify-send -u critical "AirpodsMax" "❌ Unable to connect (Busy/Timeout).\nCheck phone bluetooth."
fi

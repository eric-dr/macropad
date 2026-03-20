#!/bin/bash

# --- CONFIGURACIÓN ---
MAC_ADDR="0A:E1:68:C3:3E:8A"
PA_CARD="bluez_card.0A_E1_68_C3_3E_8A"

# 1. LIMPIEZA NUCLEAR
notify-send -u low "AirpodsMax" "Borrando registro anterior..."
rfkill unblock bluetooth
bluetoothctl scan off > /dev/null 2>&1
bluetoothctl disconnect "$MAC_ADDR" > /dev/null 2>&1
bluetoothctl remove "$MAC_ADDR" > /dev/null 2>&1

# Damos tiempo al sistema para limpiar la caché
sleep 2

# 2. EMPAREJAMIENTO POR FUERZA BRUTA
notify-send -u normal "AirpodsMax" "Emparejando desde cero..."
# Usamos el comando mágico que te ha funcionado (-t 0)
sudo btmgmt pair -c 3 -t 0 "$MAC_ADDR"

# 3. CONFIAR Y BUCLE DE CONEXIÓN
bluetoothctl trust "$MAC_ADDR" > /dev/null 2>&1

connected=false
for i in {1..3}; do
    echo "Intento de conexión $i..."
    if bluetoothctl connect "$MAC_ADDR"; then
        connected=true
        break
    fi
    sleep 2
done

# 4. SI SE CONECTÓ, CONFIGURAMOS AUDIO
if [ "$connected" = true ]; then
    
    # Esperamos a que PulseAudio reconozca la tarjeta
    sleep 2

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
        notify-send -u normal "AirpodsMax" "⚠️ Connected but Audio sink not found."
    fi

else
    # Si fallaron los intentos
    notify-send -u normal "AirpodsMax" "❌ Unable to connect.\n¿Estaban parpadeando?"
fi

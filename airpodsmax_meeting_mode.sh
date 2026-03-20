#!/bin/bash

# --- CONFIGURACIÓN ---
MAC_ADDR="0A:E1:68:C3:3E:8A"
PA_CARD="bluez_card.0A_E1_68_C3_3E_8A"

notify-send -u normal "AirpodsMax" "Connecting Meeting Mode (Mic)..."

# 1. LIMPIEZA PREVIA (CRUCIAL PARA EVITAR BUSY)
rfkill unblock bluetooth
# Paramos escaneo para liberar ancho de banda
bluetoothctl scan off > /dev/null 2>&1
# Desconectamos fantasma
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
    # Si falla, esperamos un poco
    sleep 2
done

# 3. SI SE CONECTÓ, CONFIGURAMOS PERFILES
if [ "$connected" = true ]; then
    
    # Esperamos a que PulseAudio reconozca la tarjeta
    sleep 4

    # --- PASO CLAVE: RESETEO DE PERFIL ---
    # Primero forzamos A2DP (Música) para estabilizar la conexión.
    # Muchos clones fallan si intentas ir directo a HFP.
    pactl set-card-profile "$PA_CARD" a2dp_sink
    sleep 2

    # --- ACTIVAR MICROFONO (HFP/HSP) ---
    if pactl set-card-profile "$PA_CARD" handsfree_head_unit; then
        STATUS="Perfil: HFP (Micrófono ON)"
    else
        STATUS="(Error al activar Micro)"
        notify-send -u critical "Error" "No se pudo activar el perfil de llamada."
    fi
    
    # Esperamos a que aparezcan los nuevos dispositivos de entrada/salida
    sleep 1

    # 4. CONFIGURAR SALIDA (Lo que escuchas - Mono)
    SINK_NAME=$(pactl list sinks short | grep "0A_E1_68_C3_3E_8A" | awk '{print $2}' | head -n 1)
    
    if [ -n "$SINK_NAME" ]; then
        pactl set-default-sink "$SINK_NAME"
        
        # Mover audio activo (Spotify, Teams...)
        pactl list short sink-inputs | awk '{print $1}' | while read stream_id; do
            pactl move-sink-input "$stream_id" "$SINK_NAME"
        done
    fi

    # 5. CONFIGURAR ENTRADA (Tu voz - Micro)
    SOURCE_NAME=$(pactl list sources short | grep "0A_E1_68_C3_3E_8A" | awk '{print $2}' | head -n 1)

    if [ -n "$SOURCE_NAME" ]; then
        pactl set-default-source "$SOURCE_NAME"
        
        # Subir volumen del micro al 100% (Los clones suelen venir bajos)
        pactl set-source-volume "$SOURCE_NAME" 100%

        # Mover aplicaciones que estén usando micro ahora mismo
        pactl list short source-outputs | awk '{print $1}' | while read stream_id; do
            pactl move-source-output "$stream_id" "$SOURCE_NAME"
        done
        
        notify-send -u normal "AirpodsMax Meeting" "✅ Connected with MIC.\n$STATUS"
    else
        notify-send -u normal "AirpodsMax Meeting" "⚠️ Connected but Microphone not found."
    fi

else
    # Si fallaron los 3 intentos
    notify-send -u critical "AirpodsMax" "❌ Unable to connect (Busy/Timeout).\nCheck phone bluetooth."
fi

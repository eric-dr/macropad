#!/bin/bash

# --- CONFIGURATION ---
MAC_ADDR="18:3F:70:BB:2A:87"
# PulseAudio uses underscores instead of colons for card names
PA_CARD="bluez_card.18_3F_70_BB_2A_87"

# 1. Notify User
notify-send -u low "🎧 Music Mode" "Connecting..."

# 2. Unblock and Connect
rfkill unblock bluetooth
if bluetoothctl connect "$MAC_ADDR"; then
    
    # Wait for Ubuntu to register the device audio
    sleep 4

    # 3. Force High Fidelity Profile (A2DP)
    # WARNING: This disables the microphone
    if pactl set-card-profile "$PA_CARD" a2dp_sink; then
        STATUS="Profile: High Fidelity (A2DP)"
    else
        STATUS="(Could not force A2DP)"
    fi

    # 4. Set as Default Output
    SINK_NAME=$(pactl list sinks short | grep "$PA_CARD" | awk '{print $2}' | head -n 1)
    if [ -n "$SINK_NAME" ]; then
        pactl set-default-sink "$SINK_NAME"
    fi

    notify-send -u normal "🎧 Music Mode" "✅ AirPods de Èric connected.\n$STATUS"

else
    notify-send -u critical "🎧 Music Mode" "❌ AirPods de Èric connection failed.\nCheck power."
fi
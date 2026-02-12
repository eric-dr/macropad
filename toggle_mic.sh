#!/bin/bash

# 1. Hacer el cambio (Toggle) en el micro por defecto
pactl set-source-mute @DEFAULT_SOURCE@ toggle

# 2. Comprobar cómo ha quedado (para avisarte)
# "yes" significa que está muteado.
IS_MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -o "yes")

if [ "$IS_MUTED" = "yes" ]; then
    # Notificación CRÍTICA (roja o persistente según tema)
    notify-send -u normal "🎙️ MICROFONO" "🔴 SILENCIADO (Nadie te oye)"
    
    # Opcional: Sonido de feedback (bip grave)
    # paplay /usr/share/sounds/freedesktop/stereo/audio-channel-front-right.oga
else
    # Notificación NORMAL
    notify-send -u normal "🎙️ MICROFONO" "🟢 ACTIVO (Te escuchan)"
    
    # Opcional: Sonido de feedback (bip agudo)
    # paplay /usr/share/sounds/freedesktop/stereo/audio-channel-front-left.oga
fi

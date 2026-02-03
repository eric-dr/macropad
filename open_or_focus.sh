#!/bin/bash

# $1 = Palabra clave
# $2 = Comando

KEYWORD="$1"
COMMAND="$2"

# --- ZONA DE SEGURIDAD (CANDADO) ---
LOCKDIR="/tmp/youtube_macro_lock_folder"

# Intentamos poner el candado. Si ya está puesto, ADIÓS.
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    exit 0
fi

# Aseguramos quitar el candado al terminar
trap "rmdir '$LOCKDIR'" EXIT

# --- LÓGICA ---
# Buscamos la ventana
WINDOW_ID=$(wmctrl -lx | grep -i "$KEYWORD" | awk '{print $1}' | head -n 1)

if [ -n "$WINDOW_ID" ]; then
    # SI EXISTE: Enfocar
    xdotool windowmap "$WINDOW_ID"
    xdotool windowactivate "$WINDOW_ID"
else
    # SI NO EXISTE: Lanzar
    # Quitamos el pgrep porque podía dar problemas
    setsid $COMMAND >/dev/null 2>&1 &
    
    # Bloqueamos durante 3 segundos para evitar repeticiones
    sleep 3
fi

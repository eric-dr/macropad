#!/bin/bash

# $1 = Palabras clave separadas por | (ej: "Error|Portal")
# $2... = Comando para lanzar la app
KEYWORD="$1"
shift
COMMAND="$@"

# 1. Buscamos la ventana usando Expresión Regular Extendida (-E) 
# Esto permite buscar "Palabra1|Palabra2"
# Buscamos en el título (-l) excluyendo la propia terminal
WINDOW_ID=$(wmctrl -l | grep -Ei "$KEYWORD" | grep -ivE "terminator|terminal|open_or_focus" | awk '{print $1}' | head -n 1)

# 2. Si no hay ID, probamos buscando por la Clase (para Spotify/YouTube)
if [ -z "$WINDOW_ID" ]; then
    WINDOW_ID=$(wmctrl -lx | grep -Ei "$KEYWORD" | awk '{print $1}' | head -n 1)
fi

# 3. Lógica de acción
if [ -n "$WINDOW_ID" ]; then
    echo "Ventana encontrada ($WINDOW_ID). Enfocando..."
    wmctrl -i -a "$WINDOW_ID"
    xdotool windowactivate "$WINDOW_ID"
else
    echo "No encontrado. Lanzando: $COMMAND"
    # Ejecutamos el comando en segundo plano de forma independiente
    setsid $COMMAND > /dev/null 2>&1 &
fi

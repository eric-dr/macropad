#!/bin/bash

IMAGEN="/home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/macropad_legend.png"
VISOR="eog"

# ¿Está abierto?
PID=$(pgrep -f "$VISOR.*$IMAGEN")

if [ -n "$PID" ]; then
    # Está abierto → cerrarlo
    kill $PID
else
    # No está abierto → abrirlo
    $VISOR "$IMAGEN" &
fi


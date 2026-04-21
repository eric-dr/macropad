#!/bin/bash

# $1 = Keyword (spotify, YouTubeApp)
# $2 = Command to launch the app

KEYWORD="$1"
COMMAND="$2"

# 1. SPECIAL CASE FOR SPOTIFY (Snap version)
if [[ "$KEYWORD" == "spotify" ]]; then
    # Use DBus to tell Spotify to "Present" its window (Works even if minimized)
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Spotify.Present > /dev/null 2>&1
    
    # Wait a bit and try to force focus with xdotool/wmctrl as backup
    WINDOW_ID=$(wmctrl -l | grep -i "Spotify" | awk '{print $1}' | head -n 1)
    if [ -n "$WINDOW_ID" ]; then
        wmctrl -i -a "$WINDOW_ID"
        xdotool windowactivate "$WINDOW_ID"
        exit 0
    fi
fi

# 2. GENERAL CASE (YouTube and others)
WINDOW_ID=$(wmctrl -lx | grep -i "$KEYWORD" | awk '{print $1}' | head -n 1)

if [ -n "$WINDOW_ID" ]; then
    wmctrl -i -a "$WINDOW_ID"
    xdotool windowactivate "$WINDOW_ID"
else
    # Launch if not found
    nohup $COMMAND > /dev/null 2>&1 &
fi

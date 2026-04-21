print("Macropad 3 Buttons")

import board

from kmk.kmk_keyboard import KMKKeyboard
from kmk.keys import KC
from kmk.scanners import DiodeOrientation
from kmk.extensions.media_keys import MediaKeys
from kmk.modules.holdtap import HoldTap, HoldTapRepeat

keyboard = KMKKeyboard()
keyboard.extensions.append(MediaKeys())
keyboard.modules.append(HoldTap())

# --- CORRECCIÓN DE PINES ---
# He invertido el orden aquí. Antes era (GP3, GP5, GP6).
# Al ponerlo al revés, el botón que antes el código creía que era el último,
# ahora será el primero (Izquierda).
keyboard.col_pins = (board.GP6, board.GP5, board.GP3,)
keyboard.row_pins = (board.GP4,)
keyboard.diode_orientation = DiodeOrientation.COL2ROW

# --- DEFINICIÓN DE ATAJOS ---
CMD_SPOTIFY = KC.LCTRL(KC.LALT(KC.S))
CMD_YOUTUBE = KC.LCTRL(KC.LALT(KC.Y))

# --- DEFINICIÓN DE BOTONES ---

# 1. BOTÓN APPS (Para poner a la Izquierda)
# repeat=HoldTapRepeat.NONE es la clave: asegura que aunque mantengas,
# solo envíe la señal UNA vez.
BTN_APPS = KC.HT(
    tap=CMD_SPOTIFY,
    hold=CMD_YOUTUBE,
    prefer_hold=False,
    tap_time=1000,
    repeat=HoldTapRepeat.NONE 
)

# 2. BOTÓN MEDIA (Para el Centro)
BTN_MEDIA = KC.HT(
    tap=KC.MEDIA_PLAY_PAUSE,
    hold=KC.MEDIA_NEXT_TRACK,
    prefer_hold=False,
    tap_time=1000,
    repeat=HoldTapRepeat.NONE
)

# 3. BOTÓN VOLUMEN (Para la Derecha)
# Aquí SI queremos repetición (HOLD) para bajar volumen rápido
BTN_VOL = KC.HT(
    tap=KC.AUDIO_VOL_UP,
    hold=KC.AUDIO_VOL_DOWN,
    prefer_hold=False,
    tap_time=200,
    repeat=HoldTapRepeat.HOLD
)

# --- MAPA DE TECLAS ---
# Ahora que los pines están invertidos arriba (6, 5, 3),
# este orden debería coincidir con tu mesa: Izq, Centro, Der.
keyboard.keymap = [
    [BTN_APPS, BTN_MEDIA, BTN_VOL,]
]

if __name__ == '__main__':
    keyboard.go()

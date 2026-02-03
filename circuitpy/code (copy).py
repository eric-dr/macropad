print("Starting")

import board

from kmk.kmk_keyboard import KMKKeyboard
from kmk.keys import KC
from kmk.scanners import DiodeOrientation
from kmk.extensions.media_keys import MediaKeys
from kmk.modules.holdtap import HoldTap
from kmk.modules.holdtap import HoldTapRepeat


keyboard = KMKKeyboard()
keyboard.extensions.append(MediaKeys())
keyboard.modules.append(HoldTap())

keyboard.col_pins = (board.GP3,board.GP5,board.GP6,)
keyboard.row_pins = (board.GP4,)
keyboard.diode_orientation = DiodeOrientation.COL2ROW

MIC = KC.LCTRL(KC.LSFT(KC.M))
PTT = KC.LCTRL(KC.SPC)
CAM = KC.LCTRL(KC.LSFT(KC.O))
HAND = KC.LCTRL(KC.LSFT(KC.K))
VOLU = KC.AUDIO_VOL_UP
VOLD = KC.AUDIO_VOL_DOWN

Key4 = KC.HT(MIC, PTT, prefer_hold=True, tap_interrupted=False, tap_time=200)
Key5 = KC.HT(CAM, HAND, prefer_hold=True, tap_interrupted=False, tap_time=200)
Key6 = KC.HT(VOLU, VOLD, prefer_hold=True, tap_interrupted=False, tap_time=200,repeat=HoldTapRepeat.NONE)

keyboard.keymap = [
    [Key6, Key5, Key4,]
]

if __name__ == '__main__':
    keyboard.go()

# Macropad Control & Automation (Ubuntu 24.04)

This repository contains a collection of Bash scripts and configurations designed to turn a custom Macropad into a powerful productivity workstation on Ubuntu 24.04 (Noble Numbat).

## 1. Required Dependencies

Install these packages to enable window management, audio control, terminal customization, and hardware support.

COMMANDS:
sudo apt update
sudo apt install terminator python3-nautilus wmctrl xdotool pulseaudio-utils -y
sudo apt install bluez libspa-0.2-bluetooth -y
sudo apt install gnome-shell-extension-manager -y
sudo apt install libcamhal-ipu6 libcamhal-ipu6-common v4l2-relayd intel-vsc-firmware -y

CRITICAL: For the "Focusing" feature (bringing windows to the front) to work properly, you must log in using Ubuntu on Xorg. Click the gear icon (⚙️) on the login screen before entering your password.

---

## 2. Discovery: Finding your Device Info

Use these commands to identify your hardware IDs and update the scripts:

A. Find Bluetooth MAC Addresses:
bluetoothctl devices
(Radar mode for clones): sudo btmgmt find -l | grep -B 1 "rssi -[2-5][0-9]"

B. Find Window Classes (For App Focusing):
wmctrl -lx
(Look at the third column, e.g., spotify.Spotify)

C. Find Audio Sink Names:
pactl list sinks short

---

## 3. Audio Management Scripts

Optimized for PipeWire (Ubuntu 24.04) with polling loops for near-instant switching.

- Music Mode (airpods_music.sh): Forces A2DP Sink (SBC). Resets profile to off first to clear stuck processes.
- Meeting Mode (airpods_meeting.sh): Forces Headset Unit (mSBC) for HD Voice. Redirects Teams/Zoom streams.
- Built-in Audio (built_in_speakers.sh): Switches audio to the internal PCI soundcard.
- USB Audio (sanyun_speakers.sh): Routes to "USB 2.0 Device" (Sanyun speakers).

---

## 4. Intelligent App Focusing

The open_or_focus.sh script prevents duplicate windows.

- Spotify (Ctrl + Alt + S): Keyword 'spotify'. Uses DBus Present signal.
- YouTube (Ctrl + Alt + Y): Keyword 'YouTubeApp'. Dedicated Chrome profile.
- Eurecat ERP (Ctrl + Alt + P): Keyword 'EurecatERP'. App Mode profile.

---

## 5. System Utilities

- Mouse Connection (mx_master.sh): Connection for MX Master 3 (MAC: CE:A8:DD:E4:97:D3).
- Global Mic Mute (toggle_mic.sh): Toggles default mic with "NORMAL" notifications.
- Button Legend Overlay (toggle_image.sh): Toggle to show/hide macropad_legend.png.

---

## 6. Setup & Folders

1. Place scripts in: ~/Documents/oof_projects/macropad/
2. Set permissions: chmod +x ~/Documents/oof_projects/macropad/*.sh
3. Configure Shortcuts: Settings -> Keyboard -> Custom Shortcuts.
4. Terminator as Default:
   sudo update-alternatives --config x-terminal-emulator
   gsettings set org.gnome.desktop.default-applications.terminal exec 'terminator'
5. YouTube AdBlock: Run "google-chrome --user-data-dir=/home/$USER/.chrome-youtube-macro" once and install uBlock Origin.

---
Maintained by: Eric Domingo

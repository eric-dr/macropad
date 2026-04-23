# Macropad Control & Automation (Ubuntu 24.04)

This repository contains a collection of Bash scripts and configurations designed to turn a custom Macropad into a powerful productivity workstation on Ubuntu 24.04 (Noble Numbat).

## 1. Required Dependencies

Install these packages to enable window management, audio control, and terminal customization.

COMMANDS:
sudo apt update
sudo apt install terminator python3-nautilus wmctrl xdotool pulseaudio-utils -y
sudo apt install bluez libspa-0.2-bluetooth -y
sudo apt install gnome-shell-extension-manager -y

CRITICAL: For the "Focusing" feature (bringing windows to the front) to work properly, you must log in using Ubuntu on Xorg. Click the gear icon (⚙️) on the login screen before entering your password.

---

## 2. Final Custom Shortcuts (Mapping Table)

Configure these in "Settings -> Keyboard -> View and Customize Shortcuts -> Custom Shortcuts".

| Function | Shortcut | Command |
| :--- | :--- | :--- |
| **Spotify** | Ctrl + Alt + S | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/open_or_focus.sh spotify spotify |
| **YouTube** | Ctrl + Alt + Y | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/open_or_focus.sh YouTubeApp "google-chrome --user-data-dir=/home/eric.domingo@local.eurecat.org/.chrome-youtube-macro --class=YouTubeApp --app=https://www.youtube.com --ozone-platform=x11" |
| **Portal ERP** | Ctrl + Alt + P | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/open_or_focus.sh "Problem loading page|Serveis i gestions personals" /snap/bin/firefox --new-window "https://eurecaterp.local.eurecat.org/EmployeeServices/Enterprise%20Portal/default.aspx?&WDPK=initial&WMI=EPPersonalInformation&redirected=1&WCMP=ecat&WMI=EPPersonalInformation" |
| **AirPods Music** | Ctrl + Alt + X | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/airpods_music_mode.sh |
| **AirPods Meeting** | Ctrl + Alt + Z | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/airpods_meeting_mode.sh |
| **Sanyun USB Spk** | Ctrl + Alt + N | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/sanyun_speakers.sh |
| **Built-in Spk** | Ctrl + Alt + B | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/built_in_speakers.sh |
| **Toggle Mic** | Ctrl + Alt + I | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/toggle_mic.sh |
| **Legend Toggle** | Ctrl + Alt + M | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/toggle_image.sh |

---

## 3. Portal ERP & Firefox Setup

To ensure the Portal ERP script works correctly, the following conditions must be met:

1. **Firefox Snap:** The script explicitly calls `/snap/bin/firefox`. Ensure Firefox is installed via Snap (default in Ubuntu 24.04) and any other versions (like Firefox-ESR) are removed to avoid window detection conflicts.
2. **VPN Requirement:** The portal is an internal resource. You **must be connected to the Eurecat VPN** to see the actual content ("Serveis i gestions personals").
3. **Window Logic:** The script is designed to handle both the "Problem loading page" (offline/no VPN) and the active portal titles. It will focus the existing window in either case instead of opening duplicates.

---

## 4. Audio & Hardware Logic

### AirPods Max (clones) - MAC: 18:3F:70:BB:2A:87
The scripts are optimized for PipeWire.
- **Music Mode:** Forces A2DP Sink (SBC Codec). It resets the profile to 'off' first to clear any stuck processes.
- **Meeting Mode:** Forces Headset Unit (mSBC Codec) for HD Voice.

### Speaker Routing
- **Sanyun:** Targets "USB 2.0 Device" and moves active audio streams immediately.
- **Built-in:** Switches audio back to the internal soundcard and default microphone.

---

## 5. Setup & Maintenance

1. **Scripts Directory:** Save all scripts in `/home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/`.
2. **Permissions:** Run `chmod +x /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/*.sh`.
3. **Terminator:**
   - Set as default: `sudo update-alternatives --config x-terminal-emulator`.
   - Right-click fix: Install `python3-nautilus` and place the `terminator.py` script in `~/.local/share/nautilus-python/extensions/`.
4. **YouTube AdBlock:** Run the dedicated profile once and install **uBlock Origin**:
   `google-chrome --user-data-dir=/home/eric.domingo@local.eurecat.org/.chrome-youtube-macro`
5. **GNOME Extensions:** Install "Focus My Window" to skip the "Window is ready" notification.

---
Maintained by: Eric Domingo
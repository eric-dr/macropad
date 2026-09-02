# Macropad Control & Automation (Ubuntu 24.04)

This repository contains a collection of Bash scripts and configurations designed to turn a custom Macropad into a powerful productivity workstation on **Ubuntu 24.04 (Noble Numbat)**.

## 1. Required Dependencies

Install these packages to enable window management, audio control, terminal customization, and hardware support.

### Installation Commands:
sudo apt update
sudo apt install terminator python3-nautilus wmctrl xdotool pulseaudio-utils -y
sudo apt install bluez libspa-0.2-bluetooth -y
sudo apt install gnome-shell-extension-manager -y

> **CRITICAL:** For the "Focusing" feature (bringing windows to the front) to work properly, you **must** log in using **Ubuntu on Xorg**. Click the gear icon (gear) on the login screen before entering your password.

---

## 2. Final Custom Shortcuts (Mapping Table)

Configure these in **Settings -> Keyboard -> View and Customize Shortcuts -> Custom Shortcuts**.

| Function | Shortcut | Command |
| :--- | :--- | :--- |
| **Spotify** | Ctrl + Alt + S | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/open_or_focus.sh spotify spotify |
| **YouTube** | Ctrl + Alt + Y | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/open_or_focus.sh YouTubeApp "google-chrome --user-data-dir=/home/eric.domingo@local.eurecat.org/.chrome-youtube-macro --class=YouTubeApp --app=https://www.youtube.com --ozone-platform=x11" |
| **Portal ERP** | Ctrl + Alt + P | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/open_or_focus.sh EurecatERP "google-chrome --user-data-dir=/home/eric.domingo@local.eurecat.org/.chrome-eurecat-erp --class=EurecatERP --app=https://eurecaterp.local.eurecat.org/EmployeeServices/Enterprise%20Portal/default.aspx?&WDPK=initial&WMI=EPPersonalInformation&redirected=1&WCMP=ecat&WMI=EPPersonalInformation --ozone-platform=x11" |
| **AirPods Music** | Ctrl + Alt + X | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/airpods_music_mode.sh |
| **AirPods Meeting** | Ctrl + Alt + Z | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/airpods_meeting_mode.sh |
| **Sanyun USB Spk** | Ctrl + Alt + N | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/sanyun_speakers.sh |
| **Built-in Spk** | Ctrl + Alt + B | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/built_in_speakers.sh |
| **Toggle Mic** | Ctrl + Alt + I | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/toggle_mic.sh |
| **Legend Toggle** | Ctrl + Alt + M | /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/toggle_image.sh |

---

## 3. Portal ERP & Chrome Setup

To ensure the Portal ERP script works correctly, the following conditions must be met:

1. **VPN Requirement:** The portal is an internal resource. You **must be connected to the Eurecat VPN** to see the actual content.
2. **Dedicated Profile:** The script uses a separate Chrome profile (`.chrome-eurecat-erp`). You will need to log in the first time you use it.
3. **Window Logic:** By using `--class=EurecatERP`, the `open_or_focus.sh` script identifies the window instantly and brings it to the front, even if the page title changes (e.g., during a "Problem loading page" error).

---

## 4. AirPods & Bluetooth Advanced Configuration

Genuine AirPods (Max/Pro) require specific system tweaks in Ubuntu 24.04 to enable the microphone (HFP/mSBC) and ensure stability.

### A. Bluetooth System Config
Edit `/etc/bluetooth/main.conf` and ensure the following lines are active:
- ControllerMode = dual
- Experimental = true
- FastConnectable = true

### B. PipeWire / WirePlumber Config (mSBC Support)
Create the file `~/.config/wireplumber/wireplumber.conf.d/11-bluetooth-apple.conf` and paste:
monitor.bluez.properties = {
  bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hfp_hf hfp_ag hsp_hs hsp_ag ]
  bluez5.codecs = [ sbc sbc_xq aac msbc cvsd ]
  bluez5.enable-msbc = true
}

### C. Accidental Unmute Prevention (Double Protection)
1. **Meeting Mode Script:** Automatically sets Mic Volume to 0% and Mute to ON upon connection.
2. **Toggle Mic Script:** Alternates between "Mute OFF + 30% Volume" and "Mute ON + 0% Volume".
3. **Teams Settings:**
   - **Sync device buttons:** MUST BE OFF.
   - **Automatically adjust mic sensitivity:** MUST BE OFF.

---

## 5. Speaker Routing
- **Sanyun:** Targets "USB 2.0 Device" and moves active audio streams immediately using `pactl move-sink-input`.
- **Built-in:** Switches audio back to the internal PCI soundcard and default microphone.

---

## 6. Setup & Maintenance

1. **Scripts Directory:** Save all scripts in `/home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/`.
2. **Permissions:** Run `chmod +x /home/eric.domingo@local.eurecat.org/Documents/oof_projects/macropad/*.sh`.
3. **Terminator:**
   - Set as default: `sudo update-alternatives --config x-terminal-emulator`.
   - Right-click fix: Install `python3-nautilus` and place the `terminator.py` script in `~/.local/share/nautilus-python/extensions/`.
4. **AdBlock:** Run the dedicated profiles once and install **uBlock Origin**:
   - YouTube: `google-chrome --user-data-dir=/home/eric.domingo@local.eurecat.org/.chrome-youtube-macro`
   - ERP: `google-chrome --user-data-dir=/home/eric.domingo@local.eurecat.org/.chrome-eurecat-erp`
5. **GNOME Extensions:** Install **"Focus My Window"** via Extension Manager to skip the "Window is ready" notification.

---
Maintained by: Eric Domingo
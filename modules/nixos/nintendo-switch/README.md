# Nintendo Switch Console & Sunshine Streaming Module (`phoenix86`)

## Directory Structure

* `default.nix` — User (`nintendo-switch`), Intel Iris Xe GPU, PipeWire HDMI audio, Greetd/Gamescope session, and Pegasus Frontend wrapper derivations.
* `sunshine.nix` — Headless 1080p60 EDID (`HDMI-A-1`), Sunshine KMS + VAAPI streaming, `evsieve` button remapping, and `tailscale0` firewall rules.
* `scripts/set-switch-controllers.py` — Configures Eden controller slots (`player_0..3`), per-player vibration, and exit hotkeys from Pegasus presets.
* `scripts/update-pegasus-metadata.py` — Indexes `.nsp`/`.xci` ROMs against TitleDB, downloads artwork, and builds the `Controllers` and `Tools` tabs.

## Why Vibration Is Disabled on Moonlight Controllers (`uinput` + `evsieve` Deadlock)

When streaming via Moonlight with *"Swap A/B and X/Y"* enabled on iOS/iPadOS (so the on-screen touch overlay displays the Nintendo Switch `A`/`B`/`X`/`Y` layout):

1. **Two Virtual Gamepads Exist:**
   * **Sunshine** spawns `"Sunshine X-Box One (virtual) pad"` (`/dev/input/eventX`) via `/dev/uinput`, which advertises rumble (`EV_FF`) capability.
   * **`evsieve`** (`sunshine-pad-remap@.service`) grabs `eventX` (`EVIOCGRAB`) to swap `A`↔`B` and `X`↔`Y` back to Switch button codes and outputs `"Sunshine Moonlight Switch Pad"` (`/dev/input/eventY`), which does **not** advertise `EV_FF`.
2. **The Kernel / SDL3 Mutex Deadlock:**
   * Linux's `EVIOCGRAB` blocks other processes from *reading* button events on `eventX`, but still allows `libSDL3` (used by Eden) to `open()` `eventX` and issue force-feedback `ioctl()` calls (`LINUX_JoystickRumble`).
   * When a game triggers controller vibration (e.g., a cooking timer boiling in *Overcooked! 2*), Eden's `SDL_Vibration` thread locks SDL's global `SDL_joysticks_lock` mutex and calls `ioctl()` on `eventX`.
   * Because `eventX` is grabbed by `evsieve`, the kernel `/dev/uinput` subsystem sleeps indefinitely in uninterruptible kernel wait (`UI_FF_UPLOAD`) while holding `SDL_joysticks_lock`.
   * Next frame, `CPUCore_3` (`SendVibrationValue`) and the main thread (`SDL_PumpEvents`) block waiting for `SDL_joysticks_lock`, freezing the game and ignoring `SIGKILL (-9)` until `sunshine.service` closes `/dev/uinput`.
3. **The Two-Layer Fix:**
   * **OS Layer (`sunshine.nix`):** `ExecStartPre = "chmod 0600 /dev/input/%I"` restricts the raw Sunshine `eventX` node to `root` only, so Eden and Pegasus only ever see the rumble-free `evsieve` pad.
   * **Emulator Layer (`set-switch-controllers.py`):** Automatically sets `player_X_vibration_enabled=false` for any player slot assigned to `moonlight`, while keeping `player_X_vibration_enabled=true` for physical `8bitdo` controllers.

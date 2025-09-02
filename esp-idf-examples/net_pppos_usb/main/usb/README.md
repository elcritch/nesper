USB Networking Modes (PPP and NCM)

Overview
- PPPoS dual-CDC (default):
  - CDC0 = PPP data channel for `esp_netif`.
  - CDC1 = USB console/log output via TinyUSB console.
  - Files: `ppp_connect_usb_dualcdc.nim`, `ppp_connect_usb_dualcdc.c`.

- NCM-as-Ethernet dual-CDC:
  - Networking over TinyUSB NCM bound to an Ethernet-like `esp_netif`.
  - CDC1 = USB console/log output via TinyUSB console.
  - File: `tusb_ncm_eth_dualcdc.nim`.

Alternate (bridge) example
- `tusb_ncm.nim`: Bridges USB NCM <-> WiFi STA (packets forward both ways). Not used by `main.nim` by default.

Selecting Mode
- Default (PPPoS + CDC console): build as-is.
- NCM-as-Ethernet + CDC console: pass `-d:RUN_NCM` to Nim build (e.g., in your Atlas task or Nim command).
  - `main.nim` imports and runs `usb/tusb_ncm_eth_dualcdc.runUsbNcmEthWithConsole()` when `RUN_NCM` is defined.

Kconfig Requirements
- Common:
  - Enable TinyUSB device stack.
  - Enable CDC class; set CDC count accordingly (2 for dual console + data).
- PPP mode:
  - LWIP → Enable PPP support.
- NCM-as-Ethernet mode:
  - TinyUSB → Enable NET (NCM) device class.
  - DHCP client runs on the device (default ETH netif config). Ensure host provides DHCP or set static IP as needed.

Host Expectations
- PPPoS:
  - Host sees two serial ports. Attach PPP dialer to CDC0; logs on CDC1.
- NCM-as-Ethernet:
  - Host enumerates a USB network interface. Device requests IP via DHCP; logs on CDC1.

Useful Tweaks
- CDC RX/TX buffer size: TinyUSB → CDC → adjust `CONFIG_TINYUSB_CDC_RX_BUFSIZE`/`TX_BUFSIZE`.
- Console over USB: handled via `esp_tusb_init_console(TINYUSB_CDC_ACM_1)` in the dual-CDC samples.

Entrypoints
- PPP: `examplePppConnectDualCdc()` / `examplePppShutdownDualCdc()`.
- NCM ETH: `runUsbNcmEthWithConsole()` / `stopUsbNcmEthWithConsole()`.


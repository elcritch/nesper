PPPoS over USB CDC (dual CDC)

Overview
- CDC ACM 0: PPP data channel feeding `esp_netif` (PPPoS)
- CDC ACM 1: TinyUSB console for ESP logs and stdio

Files
- `ppp_connect_usb_dualcdc.c`: C example setting up two CDC interfaces, PPP + console.
- `ppp_connect_usb_dualcdc.nim`: Nim example with equivalent behavior.

Key Config (menuconfig)
- Component config → TinyUSB → Device
  - Enable TinyUSB device stack
  - Enable CDC and set `CDC count` to `2` or more
  - Adjust CDC RX/TX buffer sizes as needed
- Component config → LWIP
  - Enable PPP support (esp-netif PPP)

Usage Notes
- PPP frames are read from CDC0 and passed to `esp_netif_receive`; TCP/IP replies transmit via CDC0.
- Console/log output is redirected to CDC1 using `esp_tusb_init_console(TINYUSB_CDC_ACM_1)`.
- On the host, two serial devices will appear; attach your PPP dialer to the first, and a terminal to the second for logs.

API Entrypoints
- C: `example_ppp_connect_dualcdc()` / `example_ppp_shutdown_dualcdc()`
- Nim: `examplePppConnectDualCdc()` / `examplePppShutdownDualCdc()`

References
- `ppp_connect_usb.c`: single-CDC PPPoS reference (upstream ESP-IDF example)
- `tests/c_headers/idf-usb/device/tusb_console/main/tusb_console_main.c`: TinyUSB console redirection
- `tusb_composite_msc_serialdevice.nim`: example TinyUSB CDC usage from Nim


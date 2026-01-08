
import esp/driver/uart
import queues

import consts
import general
import esp/esp_intr_alloc
import gpios

export uart
export consts
export gpios.gpio_num_t

# import bytesequtils

const TAG = "uarts"


type
  Uart* = ref object
    port*: uart_port_t
    config*: uart_config_t
    events*: QueueHandle_t

const SerialNoChange* = gpio_num_t(-1)

when ESP_IDF_MAJOR == 4:
  proc newUartConfig*(baud_rate: int = 115_200;
                      data_bits: uart_word_length_t = UART_DATA_8_BITS;
                      parity: uart_parity_t = UART_PARITY_DISABLE;
                      stop_bits: uart_stop_bits_t = UART_STOP_BITS_1;
                      flow_ctrl: uart_hw_flowcontrol_t = UART_HW_FLOWCTRL_DISABLE,
                      rx_flow_ctrl_thresh: uint8 = 122,
                      use_ref_tick: bool = false,
                      ): uart_config_t =

    result = uart_config_t(
      baud_rate: baud_rate.cint,
      data_bits: data_bits,
      parity: parity,
      stop_bits: stop_bits,
      flow_ctrl: flow_ctrl,
      rx_flow_ctrl_thresh: rx_flow_ctrl_thresh,
      use_ref_tick: use_ref_tick
    )
elif ESP_IDF_MAJOR >= 5:
  proc newUartConfig*(baud_rate: int = 115_200;
                      data_bits: uart_word_length_t = UART_DATA_8_BITS;
                      parity: uart_parity_t = UART_PARITY_DISABLE;
                      stop_bits: uart_stop_bits_t = UART_STOP_BITS_1;
                      flow_ctrl: uart_hw_flowcontrol_t = UART_HW_FLOWCTRL_DISABLE,
                      rx_flow_ctrl_thresh: uint8 = 122,
                      source_clk: uart_sclk_t = UART_SCLK_DEFAULT,
                      allow_pd: bool = false,
                      backup_before_sleep: bool = false,
                      ): uart_config_t =

    result = uart_config_t(
      baud_rate: baud_rate.cint,
      data_bits: data_bits,
      parity: parity,
      stop_bits: stop_bits,
      flow_ctrl: flow_ctrl,
      rx_flow_ctrl_thresh: rx_flow_ctrl_thresh,
      source_clk: source_clk,
      flags: uart_config_flags_t(
        allow_pd: (if allow_pd: 1'u32 else: 0'u32),
        backup_before_sleep: (if backup_before_sleep: 1'u32 else: 0'u32)
      )
    )

proc newUart*(config: var uart_config_t;
              uart_num: uart_port_t;
              tx_pin: gpio_num_t; # UART TX pin GPIO number.
              rx_pin: gpio_num_t; # UART TX pin GPIO number.
              rts_pin: gpio_num_t = SerialNoChange; # UART TX pin GPIO number.
              cts_pin: gpio_num_t = SerialNoChange; # UART TX pin GPIO number.
              buffer: SzBytes,
              rx_buffer = SzBytes(-1),
              tx_buffer = SzBytes(-1),
              event_size: int = 0,
              intr_flags: set[InterruptFlags] = {}
              ): Uart =

  new(result)

  result.port = uart_num
  result.config = config

  # // Configure UART parameters
  check: uart_param_config(uart_num, addr config)

  check: uart_set_pin(uart_num,
                      tx_pin.cint,
                      rx_pin.cint,
                      rts_pin.cint,
                      cts_pin.cint)

  let
    rx_sz: cint = if rx_buffer >= SzBytes(0): rx_buffer.cint else: buffer.cint
    tx_sz: cint = if tx_buffer >= SzBytes(0): tx_buffer.cint else: buffer.cint

  var iflags = esp_intr_flags(0)
  for flg in intr_flags:
    iflags = iflags or flg.esp_intr_flags

  # // Setup UART buffered IO with event queue
  # // Install UART driver using an event queue here
  check: uart_driver_install(result.port,
                             rx_sz,
                             tx_sz,
                             event_size.cint,
                             if event_size > 0: addr result.events else: nil,
                             iflags)
  
  return

proc read*(uart: var Uart;
           size = 1024.SzBytes,
           wait: Ticks = 10.Millis): seq[byte] =

  let sz = size.uint32

  var bytes_avail = csize_t(0)
  check: uart_get_buffered_data_len(uart.port, addr bytes_avail)

  if bytes_avail == 0:
    return @[]

  else:
    var buff = newSeq[byte](bytes_avail)
    let
      bytes_read = uart_read_bytes(uart.port, addr(buff[0]), sz, wait)
    
    if bytes_read < 0:
      var bytes_read_str = $bytes_read
      raise newEspError[EspError]("uart error: " & $bytes_read_str, bytes_read)

    var nb = buff[0..<bytes_read]
    result = nb

proc write*(uart: var Uart;
            data: openArray[byte]): SzBytes {.discardable.} =

  # // Write data to UART.
  let bytes_written = uart_write_bytes(uart.port, cast[cstring](data[0].unsafeAddr), data.len().csize_t)
  
  result = bytes_written.SzBytes()

proc write*(uart: var Uart;
            data: var seq[byte],
            ): SzBytes {.discardable.} =
  # var buff = data[0..data.len]

  write(uart, data.toOpenArray(0, data.high()))


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
  SerialNoChangeTp* = distinct cint
  SerialPin* = gpio_num_t | SerialNoChangeTp

  Uart* = ref object
    port*: uart_port_t
    config*: uart_config_t
    events*: QueueHandle_t

const SerialNoChange* = SerialNoChangeTp(-1)

proc newUartConfig*(baud_rate: int = 115_200;
                    data_bits: uart_word_length_t = UART_DATA_8_BITS;
                    parity: uart_parity_t = UART_PARITY_DISABLE;
                    stop_bits: uart_stop_bits_t = UART_STOP_BITS_1;
                    flow_ctrl: uart_hw_flowcontrol_t = UART_HW_FLOWCTRL_DISABLE
                    ): uart_config_t =

  result = uart_config_t(
    baud_rate: baud_rate.cint,
    data_bits: data_bits,
    parity: parity,
    stop_bits: stop_bits,
    flow_ctrl: flow_ctrl,
  )

proc newUart*(config: var uart_config_t;
              uart_num: uart_port_t;
              tx_pin: SerialPin; # UART TX pin GPIO number.
              rx_pin: SerialPin; # UART TX pin GPIO number.
              rts_pin: SerialPin = SerialNoChange; # UART TX pin GPIO number.
              cts_pin: SerialPin = SerialNoChange; # UART TX pin GPIO number.
              buffer: SzBytes,
              rx_buffer = SzBytes(-1),
              tx_buffer = SzBytes(-1),
              event_sizes: int = 0,
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
                             event_sizes.cint,
                             addr result.events,
                             iflags)
  
  return

proc read*(uart: var Uart;
           size = 1024.SzBytes,
           wait: Ticks = 10.Millis): seq[byte] =

  let sz = size.uint32

  var buff = newSeqOfCap[byte](sz)
  let
    bytes_read = uart_read_bytes(uart.port,
                    addr(buff[0]),
                    sz,
                    wait)
  
  if bytes_read < 0:
    raise newEspError[EspError]("uart error: " & $bytes_read, bytes_read)

  result = buff[0..bytes_read]

proc write*(uart: var Uart;
            data: string,
            wait: Ticks = 10.Millis): SzBytes =

  # // Write data to UART.
  let bytes_written = uart_write_bytes(uart.port, data, data.len().csize_t)
  
  check: bytes_written 

  result = bytes_written.SzBytes()


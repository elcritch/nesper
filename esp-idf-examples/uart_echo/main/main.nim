import nesper
import nesper/esp/driver/uart
import nesper/esp/queue
import nesper/uarts

const
  sdkconfigHdr = "sdkconfig.h"

let
  CONFIG_EXAMPLE_UART_PORT_NUM* {.importc: "CONFIG_EXAMPLE_UART_PORT_NUM", header: sdkconfigHdr.}: cint
  CONFIG_EXAMPLE_UART_BAUD_RATE* {.importc: "CONFIG_EXAMPLE_UART_BAUD_RATE", header: sdkconfigHdr.}: cint
  CONFIG_EXAMPLE_UART_RXD* {.importc: "CONFIG_EXAMPLE_UART_RXD", header: sdkconfigHdr.}: cint
  CONFIG_EXAMPLE_UART_TXD* {.importc: "CONFIG_EXAMPLE_UART_TXD", header: sdkconfigHdr.}: cint
  CONFIG_EXAMPLE_TASK_STACK_SIZE* {.importc: "CONFIG_EXAMPLE_TASK_STACK_SIZE", header: sdkconfigHdr.}: cint

const
  TAG: cstring = "UART TEST"
  BUF_SIZE = 1024
  USE_HIGH_LEVEL_TASK = false

proc echoTask(arg: pointer) {.cdecl.} =
  let uartPort = uart_port_t(CONFIG_EXAMPLE_UART_PORT_NUM)

  var uartConfig: uart_config_t
  uartConfig.baud_rate = CONFIG_EXAMPLE_UART_BAUD_RATE
  uartConfig.data_bits = UART_DATA_8_BITS
  uartConfig.parity = UART_PARITY_DISABLE
  uartConfig.stop_bits = UART_STOP_BITS_1
  uartConfig.flow_ctrl = UART_HW_FLOWCTRL_DISABLE
  uartConfig.rx_flow_ctrl_thresh = 0'u8
  when ESP_IDF_MAJOR == 4:
    uartConfig.use_ref_tick = false
  elif ESP_IDF_MAJOR >= 5:
    uartConfig.source_clk = UART_SCLK_DEFAULT
    uartConfig.flags.allow_pd = 0'u32
    uartConfig.flags.backup_before_sleep = 0'u32

  let intrFlags = esp_intr_flags(0)
  var uartQueue: QueueHandle_t

  check: uart_driver_install(uartPort, (BUF_SIZE * 2).cint, 0, 0, addr uartQueue, intrFlags)
  check: uart_param_config(uartPort, addr uartConfig)
  check: uart_set_pin(uartPort,
                      CONFIG_EXAMPLE_UART_TXD,
                      CONFIG_EXAMPLE_UART_RXD,
                      UART_PIN_NO_CHANGE,
                      UART_PIN_NO_CHANGE)

  var data = newSeq[uint8](BUF_SIZE)

  while true:
    let len = uart_read_bytes(uartPort, addr data[0], uint32(BUF_SIZE - 1), 20.Millis)
    if len > 0:
      let bytesRead = len.int
      discard uart_write_bytes(uartPort, cast[cstring](addr data[0]), bytesRead.csize_t)
      data[bytesRead] = 0'u8
      logi(TAG, "Recv str: %s", cast[cstring](addr data[0]))
    elif len < 0:
      logw(TAG, "uart_read_bytes error: %d", len)

proc echoTaskHighLevel(arg: pointer) {.cdecl.} =
  let uartPort = uart_port_t(CONFIG_EXAMPLE_UART_PORT_NUM)

  var uartConfig = newUartConfig(
    baud_rate = CONFIG_EXAMPLE_UART_BAUD_RATE.int,
    data_bits = UART_DATA_8_BITS,
    parity = UART_PARITY_DISABLE,
    stop_bits = UART_STOP_BITS_1,
    flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    rx_flow_ctrl_thresh = 0'u8
  )

  var uart = uartConfig.newUart(
    uartPort,
    tx_pin = gpio_num_t(CONFIG_EXAMPLE_UART_TXD),
    rx_pin = gpio_num_t(CONFIG_EXAMPLE_UART_RXD),
    buffer = BUF_SIZE.SzBytes
  )

  while true:
    var data = uart.read(BUF_SIZE.SzBytes, 20.Millis)
    if data.len > 0:
      discard uart.write(data)
      data.add(0'u8)
      logi(TAG, "Recv str (hl): %s", cast[cstring](addr data[0]))

app_main():
  if USE_HIGH_LEVEL_TASK:
    discard xTaskCreate(echoTaskHighLevel,
                        "uart_echo_task_hl",
                        CONFIG_EXAMPLE_TASK_STACK_SIZE.uint32,
                        nil,
                        10,
                        nil)
  else:
    discard xTaskCreate(echoTask,
                        "uart_echo_task",
                        CONFIG_EXAMPLE_TASK_STACK_SIZE.uint32,
                        nil,
                        10,
                        nil)

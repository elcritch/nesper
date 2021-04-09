
import nesper/serial_utils

export serial_utils


var cfg0 = newUartConfig(baud_rate = 9600)

var urt0 = cfg0.newUart(UART_NUM_0, tx_pin = GPIO_NUM_4, rx_pin = GPIO_NUM_5, bufferSizes = 2048)

# urt0.read()

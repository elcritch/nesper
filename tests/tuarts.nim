
import nesper/consts
import nesper/uarts

export uarts


var cfg0 = newUartConfig(baud_rate = 9600)

var urt0 = cfg0.newUart(UART_NUM_0,
    tx_pin = GPIO_NUM_4,
    rx_pin = GPIO_NUM_5,
    buffer = 2048.SzBytes)

# urt0.read()

echo "urt0: ", $urt0.port

var buff = urt0.read(1023.SzBytes)

urt0.write(buff)

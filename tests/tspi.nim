
import nesper/spi



#  define PIN_NUM_MISO 37
#  define PIN_NUM_MOSI 35
#  define PIN_NUM_CLK  36
#  define PIN_NUM_CS   34

let bus = SPI1_HOST.initSpiBus(miso=9, mosi=10, sclk=12, dma_channel=2, flags={})

var dev: spi_device_handle_t

let trn1 = dev.newSpiTrans([byte 1, 2])
let trn2 = dev.newSpiTrans([byte 1, 2, 3])
let trn3 = dev.newSpiTrans([byte 1, 2, 3, 4, 5])
let trn4 = dev.newSpiTrans(@[1'u8, 2, 3])

echo "trn1: " & repr(trn1)
echo "trn2: " & repr(trn2)
echo "trn3: " & repr(trn3)
echo "trn4: " & repr(trn4)

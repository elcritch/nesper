
import nesper
import nesper/spi



#  define PIN_NUM_MISO 37
#  define PIN_NUM_MOSI 35
#  define PIN_NUM_CLK  36
#  define PIN_NUM_CS   34

var dev: spi_device_handle_t

let trn1 = dev.newSpiTrans([1'u8, 2'u8, 3'u8])
let trn2 = dev.newSpiTrans([1'u8, 2'u8, 3'u8, 4'u8, 5'u8])
let trn3 = dev.newSpiTrans(@[1'u8, 2'u8, 3'u8])

echo "trn1: " & repr(trn1)
echo "trn2: " & repr(trn2)
echo "trn3: " & repr(trn3)

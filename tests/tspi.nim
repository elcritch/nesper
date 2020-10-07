
import nesper/spi



#  define PIN_NUM_MISO 37
#  define PIN_NUM_MOSI 35
#  define PIN_NUM_CLK  36
#  define PIN_NUM_CS   34

let
  bus = SPI1_HOST.initSpiBus(miso=9, mosi=10, sclk=12, dma_channel=2, flags={BUSFLAG_MASTER})

var
  dev: SpiDev =
    bus.newSpiDevice(commandlen = bits(3),
                     addresslen = bits(4),
                     mode=1, cs_io=23,
                     clock_speed_hz = 1_000_000, 
                     flags={})


let trn1 = dev.newSpiTrans([byte 1, 2])
let trn2 = dev.newSpiTrans([byte 1, 2, 3])
let trn3 = dev.newSpiTrans([byte 1, 2, 3, 4, 5])
let trn4 = dev.newSpiTrans(@[1'u8, 2, 3])

echo "trn1: " & repr(trn1)
echo "trn2: " & repr(trn2)
echo "trn3: " & repr(trn3)
echo "trn4: " & repr(trn4)

# Example: spi poll transmission
trn1.poll()

# Example spi queued transaction
trn2.queue()

# Example aquire bus
withSpiBus(dev):
  trn3.poll()
  trn4.poll()


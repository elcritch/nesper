
import nesper/spi

#  define PIN_NUM_MISO 37
#  define PIN_NUM_MOSI 35
#  define PIN_NUM_CLK  36
#  define PIN_NUM_CS   34

let
  bus = SPI1_HOST.initSpiBus(miso=9, mosi=10, sclk=12, dma_channel=2, flags={MASTER})

var
  dev: SpiDev =
    bus.addDevice(commandlen = bits(3),
                     addresslen = bits(4),
                     mode=1, cs_io=23,
                     clock_speed_hz = 1_000_000, 
                     queue_size = 10,
                     flags={HALFDUPLEX})


let tdata1 = [byte 1, 2]
let trn1 = dev.raw_trans(tdata1)

var tdata2 = [byte 1, 2, 3]
let trn2 = dev.raw_trans(tdata2)

let trn3 = dev.raw_trans([byte 1, 2, 3, 4, 5])

let tdata4 = @[1'u8, 2, 3]
let trn4 = dev.raw_trans(tdata4)

let trn5 = dev.raw_trans(@[1'u8, 2, 3, 4, 5])

echo "trn1: " & repr(trn1)
echo "trn2: " & repr(trn2)
echo "trn3: " & repr(trn3)
echo "trn4: " & repr(trn4)
echo "trn5: " & repr(trn5)

# Example: spi poll transmission
trn1.poll()

# Example spi queued transaction
trn2.queue()

# Example aquire bus
withSpiBus(dev):
  trn3.poll()
  trn4.poll()

# Regular spi transmit
trn5.transmit()


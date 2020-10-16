
import nesper/spi

#  define PIN_NUM_MISO 37
#  define PIN_NUM_MOSI 35
#  define PIN_NUM_CLK  36
#  define PIN_NUM_CS   34

let
  bus = HSPI.newSpiBus(miso=9, mosi=10, sclk=12, dma_channel=2, flags={MASTER})

var
  dev: SpiDev =
    bus.addDevice(commandlen = bits(3),
                     addresslen = bits(4),
                     mode=1, cs_io=23,
                     clock_speed_hz = 1_000_000, 
                     queue_size = 10,
                     flags={HALFDUPLEX})


let tdata1 = [byte 1, 2]
let trn1 = dev.fullTrans(tdata1)

# read non-byte number of bits
var tdata2 = [byte 1, 2, 3]
var trn2 = dev.fullTrans(tdata2, rxlength=bits(20))

var trn3 = dev.fullTrans([byte 1, 2, 3, 4, 5])

var tdata4 = @[1'u8, 2, 3]
var trn4 = dev.fullTrans(tdata4)

var trn5 = dev.readTrans(bits(24))
# this is an error: let trn5 = dev.readTrans(@[1'u8, 2, 3, 4, 5])

var trn6 = dev.writeTrans(@[1'u8, 2, 3, 4, 5])

echo "trn1: " & repr(trn1)
echo "trn2: " & repr(trn2)
echo "trn3: " & repr(trn3)
echo "trn4: " & repr(trn4)
echo "trn5: " & repr(trn5)
echo "trn5: " & repr(trn6)

# Example: spi poll fullTransmission
trn1.poll()

# Example spi queued fullTransaction
trn2.queue()

# Example aquire bus
withSpiBus(dev):
  trn3.poll()
  trn4.poll()

# Regular spi transmit
trn5.transmit()


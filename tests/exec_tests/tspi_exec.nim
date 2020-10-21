
import nesper/spis

{.emit: """

const char *esp_err_to_name(esp_err_t id) { return "ERROR"; }

esp_err_t spi_bus_initialize(spi_host_device_t host, const spi_bus_config_t *bus_config, int dma_chan) {
  return ESP_OK;
}

esp_err_t spi_bus_free(spi_host_device_t host) {
  return ESP_OK;
}

esp_err_t spi_bus_add_device(spi_host_device_t host, const spi_device_interface_config_t *dev_config, spi_device_handle_t *handle)
{ return ESP_OK; }

esp_err_t spi_bus_remove_device(spi_device_handle_t handle)
{ return ESP_OK; }

esp_err_t spi_device_queue_trans(spi_device_handle_t handle, spi_transaction_t *trans_desc, TickType_t ticks_to_wait)
{ return ESP_OK; }

esp_err_t spi_device_get_trans_result(spi_device_handle_t handle, spi_transaction_t **trans_desc, TickType_t ticks_to_wait)
{ return ESP_OK; }

esp_err_t spi_device_transmit(spi_device_handle_t handle, spi_transaction_t *trans_desc)
{ return ESP_OK; }

esp_err_t spi_device_acquire_bus(spi_device_handle_t device, TickType_t wait) 
{ return ESP_OK; }

esp_err_t spi_device_polling_start(spi_device_handle_t handle, spi_transaction_t *trans_desc, TickType_t ticks_to_wait)
{ return ESP_OK; }

esp_err_t spi_device_polling_end(spi_device_handle_t handle, TickType_t ticks_to_wait)
{ return ESP_OK; }

esp_err_t spi_device_polling_transmit(spi_device_handle_t handle, spi_transaction_t *trans_desc)
{ return ESP_OK; }

void spi_device_release_bus(spi_device_handle_t dev)
{ }

int spi_get_actual_clock(int fapb, int hz, int duty_cycle)
{ return hz; }

void spi_get_timing(bool gpio_is_used, int input_delay_ns, int eff_clk, int* dummy_o, int* cycles_remain_o)
{ }

int spi_get_freq_limit(bool gpio_is_used, int input_delay_ns)
{ return 10000000; }

""".}

#  define PIN_NUM_MISO 37
#  define PIN_NUM_MOSI 35
#  define PIN_NUM_CLK  36
#  define PIN_NUM_CS   34

let
  bus = HSPI.newSpiBus(miso=gpio_num_t(9), mosi=gpio_num_t(10), sclk=gpio_num_t(12), dma_channel=2, flags={MASTER})

var
  dev: SpiDev =
    bus.addDevice(commandlen = bits(3),
                     addresslen = bits(4),
                     mode=1, cs_io=gpio_num_t(23),
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
var res = trn5.transmit()


import math
import nesper
import nesper/gpios
import nesper/esp/driver/i2s
import nesper/esp/esp_intr_alloc # for ESP_INTR_FLAG_LEVEL1
import nesper/esp/esp_system # for esp_get_free_heap_size

const
  sample_rate = 36000
  i2s_num = I2S_NUM_0
  wave_freq_hz = 100
  bck_pin = GPIO_NUM_26
  wsel_pin = GPIO_NUM_25
  data_out_pin = GPIO_NUM_33
  data_in_pin = -1
  sample_per_cycle = sample_rate div wave_freq_hz

proc toCshort(x: float): cshort =
  let factor = 2.0^15 - 1.0
  result = cshort(factor * x)

proc setup_triangle_sine_waves() =
  echo "Free mem=", esp_get_free_heap_size(), " written data=", 4*sample_per_cycle

  var buffer: array[2*sample_per_cycle, cshort]
  var size = (len(buffer)*sizeof(cshort)).csize_t
  for i in 0..<sample_per_cycle:
    buffer[2*i] = toCshort(4*arcsin(sin(i.toFloat * TAU / 360.0))/TAU)
    buffer[2*i+1] = toCshort(sin(i.toFloat * TAU / 360.0))

  discard i2s_write(i2s_num, addr(buffer[0]), size, addr(size), 100)

app_main():
  var i2s_config = i2s_config_t(mode: i2s_mode_t(5),
    sample_rate: sample_rate,
    bits_per_sample: I2S_BITS_PER_SAMPLE_16BIT,
    channel_format: I2S_CHANNEL_FMT_RIGHT_LEFT,
    communication_format: I2S_COMM_FORMAT_I2S,
    dma_buf_count: 6,
    dma_buf_len: 60,
    use_apll: false,
    intr_alloc_flags: cint(ESP_INTR_FLAG_LEVEL1)
    )

  discard i2s_driver_install(i2s_num, addr(i2s_config), 0, nil)

  var pin_config = i2s_pin_config_t(
    bck_io_num: cint(bck_pin),
    ws_io_num: cint(wsel_pin),
    data_out_num: cint(data_out_pin),
    data_in_num: cint(data_in_pin)
    )

  discard i2s_set_pin(i2s_num, addr(pin_config))
  discard i2s_set_clk(i2s_num, sample_rate, I2S_BITS_PER_SAMPLE_16BIT, I2S_CHANNEL_STEREO)

  setup_triangle_sine_waves()

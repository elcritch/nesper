// i2s sample rate

#define EXAMPLE_I2S_NUM (I2S_NUM_0)

#define EXAMPLE_I2S_SAMPLE_RATE (40000)

#define EXAMPLE_I2S_SAMPLE_BITS (I2S_BITS_PER_SAMPLE_16BIT)

#define EXAMPLE_I2S_FORMAT (I2S_CHANNEL_FMT_ONLY_LEFT)

#define EXAMPLE_I2S_CHANNEL_NUM                                                \
  ((EXAMPLE_I2S_FORMAT < I2S_CHANNEL_FMT_ONLY_RIGHT) ? (2) : (1))

// I2S built-in ADC unit

#define I2S_ADC_UNIT ADC_UNIT_1

// I2S built-in ADC channel

#define I2S_ADC_CHANNEL ADC1_CHANNEL_6

void Sampler(void *parameter)

{

  pinMode(0, INPUT_PULLUP);

  i2s_config_t i2s_config;

  i2s_config.mode =
      (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX | I2S_MODE_ADC_BUILT_IN);

  i2s_config.sample_rate = EXAMPLE_I2S_SAMPLE_RATE;

  i2s_config.bits_per_sample = EXAMPLE_I2S_SAMPLE_BITS;

  i2s_config.communication_format =
      (i2s_comm_format_t)(I2S_COMM_FORMAT_I2S_MSB | I2S_COMM_FORMAT_I2S);

  i2s_config.channel_format = EXAMPLE_I2S_FORMAT;

  i2s_config.intr_alloc_flags = 0;

  i2s_config.dma_buf_count = 4;

  i2s_config.dma_buf_len = 400;

  i2s_config.use_apll = 0;

  adc1_config_channel_atten(I2S_ADC_CHANNEL, ADC_ATTEN_11db);

  adc1_config_width(ADC_WIDTH_12Bit);

  // install and start i2s driver

  i2s_driver_install(EXAMPLE_I2S_NUM, &i2s_config, 0, NULL);

  // init ADC pad

  i2s_set_adc_mode(I2S_ADC_UNIT, I2S_ADC_CHANNEL);

  // Use 1st timer of 4 (counted from zero).

  // Set 80 divider for prescaler (see ESP32 Technical Reference Manual for more

  // info).

  timer = timerBegin(0, 80, true);

  // Attach onTimer function to our timer.

  timerAttachInterrupt(timer, &onTimer, true);

  // Interrupt every 125 microseconds

  //  timerAlarmWrite(timer, 125, true);

  timerAlarmWrite(timer, 1000, true);

  // Start an alarm

  timerAlarmEnable(timer);

  unsigned long last_button_high_ms = millis();

  bool was_pressed = false;

  uint8_t dac_value = 0;

  i2s_adc_enable(EXAMPLE_I2S_NUM);

  for (;;)

  {

    const uint32_t count = ulTaskNotifyTake(pdFALSE, portMAX_DELAY);

    static char i2s_buf[1000];

    size_t bytes_read;

    i2s_read(EXAMPLE_I2S_NUM, (void *)i2s_buf, sizeof(i2s_buf), &bytes_read, 0);

    size_t offset = 0;

    while (bytes_read)

    {

      uint32_t sample = *(const uint16_t *)&i2s_buf[offset] & 0xFFF;

      sample += *(const uint16_t *)&i2s_buf[offset + 2] & 0xFFF;

      sample += *(const uint16_t *)&i2s_buf[offset + 4] & 0xFFF;

      sample += *(const uint16_t *)&i2s_buf[offset + 6] & 0xFFF;

      sample += *(const uint16_t *)&i2s_buf[offset + 8] & 0xFFF;

      samples[samples_head % ARRAY_SIZE(samples)] = -(sample / 5) + 2048;

      ++samples_head;

      offset += 2 * 5;

      bytes_read -= 2 * 5;
    }

    //    dacWrite(25, dac_value++);

    // Look for button presses

    const unsigned long now = millis();

    const long ms_low = now - last_button_high_ms;

    if (digitalRead(0) == HIGH) {
      last_button_high_ms = millis();
      was_pressed = false;

      if (ms_low >= FAST_PRESS_MS && ms_low < FAST_PRESS_MAX_MS) {
        fast_press = true;
      }
    } else if (!was_pressed) {
      if (ms_low >= LONG_PRESS_MS) {
        long_press = true;
        was_pressed = true;
      }
    }

    // Blink LED
    digitalWrite(13, sd_initialized ^
                         (wifi_enabled && (now % 1024) >= (1024 - 32)));
  }
}

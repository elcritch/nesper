
import ads111x

import options
import nesper
import i2cdev_utils

export ads111x, options, i2cdev_utils

import nesper/timers

const TAG = "ADS111X"

type 
  ads111x_addr_t = distinct uint8
  i2c_dev_ptr = ptr i2c_dev_t

const
  ADS111X_ADDR_TO_GND* = ads111x_addr_t(0x48)
  ADS111X_ADDR_TO_VCC* = ads111x_addr_t(0x49)
  ADS111X_ADDR_TO_SDA* = ads111x_addr_t(0x4A)
  ADS111X_ADDR_TO_SCL* = ads111x_addr_t(0x4B)

type
  Ads111xChannels* = seq[ads111x_mux_t]

  Ads111xDevice* = ref object
    dev_addr: ads111x_addr_t
    device: i2c_dev_t

  Ads111xConfig* = ref object
    dev*: Ads111xDevice
    mode*: ads111x_mode_t
    data_rate*: ads111x_data_rate_t
    muxes*: Ads111xChannels
    gain*: ads111x_gain_t


  Ads111xReading* = tuple[voltage: float32, raw: int]

const
  fn: float32 = NaN
  Ads111xReadingNone*: Ads111xReading = (voltage: fn, raw: 0)


const
  ADS111X_CHS_SINGLE_CH0*: Ads111xChannels =
    @[ADS111X_MUX_0_GND]
  ADS111X_CHS_ALL_SINGLE*: Ads111xChannels =
    @[ADS111X_MUX_0_GND, ADS111X_MUX_1_GND, ADS111X_MUX_2_GND, ADS111X_MUX_3_GND]
  ADS111X_CHS_ALL_DIFF_02*: Ads111xChannels =
    @[ADS111X_MUX_0_1, ADS111X_MUX_2_3]

const Ads111xReadingTimes*: array[ads111x_data_rate_t, Millis] = [
    Millis(125),    ## !< 8 samples per second
    Millis(63),     ## !< 16 samples per second
    Millis(32),     ## 100!< 32 samples per second
    Millis(15),     ## 100!< 64 samples per second
    Millis(8),    ## !100< 128 samples per second (default)
    Millis(4),    ## !100< 250 samples per second
    Millis(2),    ## !100< 475 samples per second
    Millis(1),     ## !100< 860 samples per second
]

converter toDevice(cfg: Ads111xConfig): i2c_dev_ptr =
  result = addr cfg.dev.device

proc get_reading(cfg: Ads111xConfig): Option[Ads111xReading] =
  #// wait for conversion end
  var busy: bool
  while busy:
    check: cfg.ads111x_is_busy(addr busy)

  #// Read result
  let gain_val = ads111x_gain_values[cfg.gain]
  var raw: int16 = 0
  if (cfg.ads111x_get_value(addr raw) == ESP_OK):
    var voltage: float32 = gain_val / ADS111X_MAX_VALUE * float(raw)
    return some((voltage, raw.int))
  else:
    return none[(float32, int)]()


proc configureDevice*(cfg: Ads111xConfig, ch: int) =
  check: cfg.ads111x_set_mode(cfg.mode) #    // Continuous conversion mode
  check: cfg.ads111x_set_data_rate(cfg.data_rate) #; // 32 samples per second
  check: cfg.ads111x_set_input_mux(cfg.muxes[ch]) #;    // positive = AIN0, negative = GND
  check: cfg.ads111x_set_gain(cfg.gain)

proc takeReadingFull*(cfg: Ads111xConfig, ch: int): Option[Ads111xReading] =
  #// (re)configure device - need to do it everytime you change mux channels 
  cfg.configureDevice(ch=ch)

  #// start conversion in single shot mode
  if cfg.mode == ADS111X_MODE_SINGLE_SHOT:
    check: ads111x_start_conversion(cfg.to_device())

  return cfg.get_reading()

proc takeReading*(cfg: Ads111xConfig, ch: int): Option[float32] =
  let val = takeReadingFull(cfg, ch)
  if val.isSome():
    return some(val.get().voltage)
  else:
    return none[float32]()

proc takeReadings*(cfg: Ads111xConfig): seq[Option[float32]] =
  result = newSeq[Option[float32]](cfg.muxes.len())
  let stagger_time: Millis = Ads111xReadingTimes[cfg.data_rate]

  for idx in 0 ..< cfg.muxes.len():
    discard cfg.takeReading(idx)
    delay(stagger_time)
    let rd = cfg.takeReading(idx)
    result[idx] = rd
    # TAG.loge("READING: %s => %s (%s)", $idx, $rd, $cfg.muxes[idx])

# // Main task
proc initAds111xDevice*(
        i2cDev: I2CDevConfig,
        i2cAddr: ads111x_addr_t = ADS111X_ADDR_TO_GND
      ): Ads111xDevice = 

  # // Setup ICs
  i2cDeviceInit()

  new(result)

  # initialize device
  check: ads111x_init_desc(
      addr result.device,
      i2cAddr.uint8(),
      i2cDev.port,
      i2cDev.sda,
      i2cDev.scl,
    )

proc newAds111xConfig*(
        dev: Ads111xDevice, 
        muxes: Ads111xChannels,
        data_rate: ads111x_data_rate_t,
        gain: ads111x_gain_t,
        mode: ads111x_mode_t = ADS111X_MODE_SINGLE_SHOT,
      ): Ads111xConfig =

  result = Ads111xConfig(
      dev: dev, 
      mode: mode,
      muxes: muxes,
      data_rate: data_rate,
      gain: gain)

  # TAG.logi("set cfg ch0: %s", repr cfg)
  
import nesper/timers
import nesper/esp/driver/dac

proc ads111xExample*() = 

  let
    i2cCfg = I2CDevConfig(port: I2C_NUM_0, sda: GPIO_NUM_23, scl: GPIO_NUM_22)
    muxes = @[ADS111X_MUX_0_GND, ADS111X_MUX_1_GND]

  var 
    dev = initAds111xDevice(i2cCfg, ADS111X_ADDR_TO_GND)
    adc = newAds111xConfig(
        dev = dev,
        muxes = muxes,
        data_rate = ADS111X_DATA_RATE_32,
        gain = ADS111X_GAIN_4V096,
      )

  let t0 = newBasicTimer()
  let d1 = 40'u8

  while true:
    check: dac_output_voltage(DAC_CHANNEL_2, d1)
    TAG.logi("set dac output: %f", float(d1)/256.0 * 3.43)
    delay(207.Millis)

    # measure(i)
    let readingCh0 = adc.takeReadingFull(0)
    if readingCh0.isSome():
      let rd = readingCh0.get()
      TAG.logi("Raw ADC ch0:: value: %d, voltage: %.04f volts", rd.raw, rd.voltage)
    else:
      TAG.logi("Unable to read ADC ch0")

    delay(100.Millis)

    let readingCh1 = adc.takeReadingFull(0)
    if readingCh1.isSome():
      let rd = readingCh1.get()
      TAG.logi("Raw ADC ch0:: value: %d, voltage: %.04f volts", rd.raw, rd.voltage)
    else:
      TAG.logi("Unable to read ADC ch0")

    echo "\n"
    delay(500.Millis)

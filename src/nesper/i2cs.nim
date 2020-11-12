
import consts
import general
import esp/gpio
import esp/esp_intr_alloc
import esp/driver/i2c

# export spi_host_device_t, spi_device_t, spi_bus_config_t, spi_transaction_t, spi_device_handle_t
export i2c
export consts.bits, consts.bytes, consts.TickType_t
export general.toBits
export gpio.gpio_num_t

const TAG = "i2cs"

type

  I2CPorts* = enum
    I2CPort0 = I2C_NUM_0           ## !< I2C port 0
    I2CPort1 = I2C_NUM_1          ## !< I2C port 1

  I2CError* = object of OSError
    code*: esp_err_t

  I2CMasterPort* = ref object
    port*: i2c_port_t
  I2CSlavePort* = ref object
    port*: i2c_port_t

  I2CPort* = I2CMasterPort | I2CSlavePort

  I2CCmd* = ref object
    handle*: i2c_cmd_handle_t

  # i2c_obj_t = distinct pointer


proc master_port_finalizer(cmd: I2CMasterPort) =
  TAG.logi("i2c port finalize")
  let ret = i2c_driver_delete(cmd.port)
  if ret != ESP_OK:
    raise newEspError[I2CError]("Error destroying i2c port (" & $esp_err_to_name(ret) & ")", ret)

proc slave_port_finalizer(cmd: I2CSlavePort) =
  TAG.logi("i2c port finalize")
  let ret = i2c_driver_delete(cmd.port)
  if ret != ESP_OK:
    raise newEspError[I2CError]("Error destroying i2c port (" & $esp_err_to_name(ret) & ")", ret)

proc cmd_finalizer(cmd: I2CCmd) =
  # I2C_CHECK(i2c_num < I2C_NUM_MAX, I2C_NUM_ERROR_STR, ESP_ERR_INVALID_ARG);
  # I2C_CHECK(p_i2c_obj[i2c_num] != NULL, I2C_DRIVER_ERR_STR, ESP_FAIL);
  TAG.logi("i2c cmd finalize")
  if cmd.handle.pointer != nil:
    i2c_cmd_link_delete(cmd.handle)

# var p_i2c_obj {.importc: "p_i2c_obj".}: UncheckedArray[i2c_obj_t]
proc initI2CDriver(
    res: var I2CPort,
    port: i2c_port_t,
    mode: i2c_mode_t, ## !< I2C mode
    sda_io_num: gpio_num_t, ## !< GPIO number for I2C sda signal
    scl_io_num: gpio_num_t, ## !< GPIO number for I2C scl signal
    clk_speed: Hertz,
    slv_rx_buf_len: csize_t,
    slv_tx_buf_len: csize_t;
    sda_pullup_en: bool, ## !< Internal GPIO pull mode for I2C sda signal
    scl_pullup_en: bool, ## !< Internal GPIO pull mode for I2C scl signal
    intr_alloc_flags: set[InterruptFlags]) =

  var iflags = esp_intr_flags(0)
  for fl in intr_alloc_flags:
    iflags = iflags or fl.esp_intr_flags

  let iret = i2c_driver_install(port, mode, slv_rx_buf_len, slv_tx_buf_len, iflags)
  if iret != ESP_OK:
    raise newEspError[I2CError]("Error initializing i2c port (" & $esp_err_to_name(iret) & ")", iret)

  var conf: i2c_config_t
  conf.mode = I2C_MODE_MASTER
  conf.sda_io_num = sda_io_num
  conf.sda_pullup_en = sda_pullup_en
  conf.scl_io_num = scl_io_num
  conf.scl_pullup_en = scl_pullup_en
  conf.master.clk_speed = clk_speed.uint32

  let ret = i2c_param_config(port, addr(conf))
  if ret != ESP_OK:
    raise newEspError[I2CError]("Error initializing i2c port (" & $esp_err_to_name(ret) & ")", ret)


proc newI2CMaster*(
    port: i2c_port_t,
    mode: i2c_mode_t, ## !< I2C mode
    sda_io_num: gpio_num_t, ## !< GPIO number for I2C sda signal
    scl_io_num: gpio_num_t, ## !< GPIO number for I2C scl signal
    clk_speed: Hertz;
    sda_pullup_en: bool = false, ## !< Internal GPIO pull mode for I2C sda signal
    scl_pullup_en: bool = false, ## !< Internal GPIO pull mode for I2C scl signal
    intr_alloc_flags: set[InterruptFlags]): I2CMasterPort =

  new(result, master_port_finalizer)
  initI2CDriver(result, port, I2C_MODE_MASTER,
                sda_io_num, scl_io_num, clk_speed,
                slv_rx_buf_len = 0, slv_tx_buf_len = 0,
                sda_pullup_en, scl_pullup_en,
                intr_alloc_flags)

proc newI2CSlave*(
    port: i2c_port_t,
    mode: i2c_mode_t, ## !< I2C mode
    sda_io_num: gpio_num_t, ## !< GPIO number for I2C sda signal
    scl_io_num: gpio_num_t, ## !< GPIO number for I2C scl signal
    clk_speed: Hertz;
    slv_rx_buf_len: csize_t,
    slv_tx_buf_len: csize_t,
    sda_pullup_en: bool = false, ## !< Internal GPIO pull mode for I2C sda signal
    scl_pullup_en: bool = false, ## !< Internal GPIO pull mode for I2C scl signal
    intr_alloc_flags: set[InterruptFlags]): I2CSlavePort =

  new(result, slave_port_finalizer)
  initI2CDriver(result, port, I2C_MODE_SLAVE,
                sda_io_num, scl_io_num, clk_speed,
                slv_rx_buf_len = slv_rx_buf_len , slv_tx_buf_len = slv_tx_buf_len,
                sda_pullup_en, scl_pullup_en,
                intr_alloc_flags)

proc newI2CCmd*(port: I2CPort): I2CCmd =
  # Creates a new I2C Command object
  new(result, cmd_finalizer)
  result.handle = i2c_cmd_link_create()

  # i2c_master_start(cmd)
  # i2c_master_write_byte(cmd, (address shl 1) or WRITE_BIT, ACK_CHECK_EN)
  # i2c_master_stop(cmd)


## 
## I2C Master ##
## 

proc i2cStart*(cmd: I2CCmd) =
  let ret = i2c_master_start(cmd.handle)
  if ret != ESP_OK:
    raise newEspError[I2CError]("start cmd error (" & $esp_err_to_name(ret) & ")", ret)

proc i2cStop*(cmd: I2CCmd) =
  let ret = i2c_master_start(cmd.handle)
  if ret != ESP_OK:
    raise newEspError[I2CError]("stop cmd error (" & $esp_err_to_name(ret) & ")", ret)

proc writeByte*(cmd: I2CCmd; data: uint8; ack_en: bool = false) = 
  let ret = i2c_master_write_byte(cmd.handle, data, ack_en)
  if ret != ESP_OK:
    raise newEspError[I2CError]("writebyte cmd error (" & $esp_err_to_name(ret) & ")", ret)

proc writeBytes*(cmd: I2CCmd; data: var seq[byte]; ack_en: bool = false) = 
  let ret = i2c_master_write(cmd.handle, addr(data[0]), data.len().csize_t, ack_en)
  if ret != ESP_OK:
    raise newEspError[I2CError]("write cmd error (" & $esp_err_to_name(ret) & ")", ret)

proc begin*(port: I2CMasterPort; cmd: I2CCmd; ticks_to_wait: TickType_t) =
  let ret = i2c_master_cmd_begin(port.port, cmd.handle, ticks_to_wait)
  if ret != ESP_OK:
    raise newEspError[I2CError]("cmd error (" & $esp_err_to_name(ret) & ")", ret)

template doI2cCommand*(port: I2CMasterPort, blk: untyped) =
  var cmd = newI2CCmd(port)
  blk
  cmd.begin()

## 
## I2C Slave ##
## 

proc writeBuffer*(port: I2CSlavePort; data: var seq[byte]; ticks_to_wait: TickType_t): cint =
  let ret = i2c_slave_write_buffer(port.port, addr(data[0]), data.len().cint, ticks_to_wait)
  if ret == ESP_FAIL:
    raise newEspError[I2CError]("slave write error (" & $esp_err_to_name(ret) & ")", ret)
  return ret

proc readBuffer*(port: I2CSlavePort; data: var seq[byte]; ticks_to_wait: TickType_t): cint =
  let ret = i2c_slave_read_buffer(port.port, addr(data[0]), data.len().csize_t, ticks_to_wait)
  if ret == ESP_FAIL:
    raise newEspError[I2CError]("slave write error (" & $esp_err_to_name(ret) & ")", ret)
  return ret

proc readBuffer*(port: I2CSlavePort; max_size: int; ticks_to_wait: TickType_t): seq[byte] =
  result = newSeq[byte](max_size)
  let ret = readBuffer(port, result, ticks_to_wait)
  result.setLen(ret)


proc i2c_slave_read_buffer*(i2c_num: i2c_port_t; data: ptr uint8; max_size: csize_t;
                           ticks_to_wait: TickType_t): cint {.
    importc: "i2c_slave_read_buffer", header: "i2c.h".}

converter toCmdHandle*(cmd: I2CCmd): i2c_cmd_handle_t = cmd.handle
converter toPort*(port: I2CPort): i2c_port_t = port.port


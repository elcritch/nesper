
import consts
import general
import esp/gpio
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

  I2CPort* = object
    port*: i2c_port_t

  I2CCmd* = object
    handle*: i2c_cmd_handle_t

  # i2c_obj_t = distinct pointer

# var p_i2c_obj {.importc: "p_i2c_obj".}: UncheckedArray[i2c_obj_t]
proc newI2CMaster*(
    port: i2c_port_t,
    mode: i2c_mode_t, ## !< I2C mode
    sda_io_num: gpio_num_t, ## !< GPIO number for I2C sda signal
    scl_io_num: gpio_num_t, ## !< GPIO number for I2C scl signal
    clk_speed: Hertz,
    sda_pullup_en: bool, ## !< Internal GPIO pull mode for I2C sda signal
    scl_pullup_en: bool, ## !< Internal GPIO pull mode for I2C scl signal
): I2CPort =

  proc i2c_driver_install*(i2c_num: i2c_port_t;
                            mode: i2c_mode_t;
                            slv_rx_buf_len: csize_t;
                            slv_tx_buf_len: csize_t;
                            intr_alloc_flags: cint
                            ): esp_err_t {. .}

  let iret = i2c_driver_install(port,
                                I2C_MODE_MASTER,
                                I2C_MASTER_RX_BUF_DISABLE,
                                I2C_MASTER_TX_BUF_DISABLE,
                                0)
  if iret != ESP_OK:
    raise newEspError[I2CError]("Error initializing i2c port (" & $esp_err_to_name(ret) & ")", ret)

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


proc newI2CCmd*(): I2CCmd =
  # Creates a new I2C Command object
  result.handle = i2c_cmd_link_create()

proc `=destroy`(cmd: var I2CCmd) =
  # I2C_CHECK(i2c_num < I2C_NUM_MAX, I2C_NUM_ERROR_STR, ESP_ERR_INVALID_ARG);
  # I2C_CHECK(p_i2c_obj[i2c_num] != NULL, I2C_DRIVER_ERR_STR, ESP_FAIL);
  if cmd.handle.pointer != nil:
    i2c_cmd_link_delete(cmd.handle)

proc initialize() =
  i2c_driver_install(i2c_port, I2C_MODE_MASTER, I2C_MASTER_RX_BUF_DISABLE,
                     I2C_MASTER_TX_BUF_DISABLE, 0)
  i2c_master_driver_initialize()

  """
    static i2c_port_t i2c_port = I2C_NUM_0;
    i2c_driver_install(i2c_port, I2C_MODE_MASTER, I2C_MASTER_RX_BUF_DISABLE, I2C_MASTER_TX_BUF_DISABLE, 0);
    i2c_master_driver_initialize();
    i2c_cmd_handle_t cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, chip_addr << 1 | WRITE_BIT, ACK_CHECK_EN);
    if (i2cset_args.register_address->count) {
        i2c_master_write_byte(cmd, data_addr, ACK_CHECK_EN);
    }
    for (int i = 0; i < len; i++) {
        i2c_master_write_byte(cmd, i2cset_args.data->ival[i], ACK_CHECK_EN);
    }
    i2c_master_stop(cmd);
    esp_err_t ret = i2c_master_cmd_begin(i2c_port, cmd, 1000 / portTICK_RATE_MS);
    i2c_cmd_link_delete(cmd);
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "Write OK");
    } else if (ret == ESP_ERR_TIMEOUT) {
        ESP_LOGW(TAG, "Bus is busy");
    } else {
        ESP_LOGW(TAG, "Write Failed");
    }
    i2c_driver_delete(i2c_port);
    return 0;
  """

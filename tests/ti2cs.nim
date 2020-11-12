##  cmd_i2ctools.c
##
##    This example code is in the Public Domain (or CC0 licensed, at your option.)
##
##    Unless required by applicable law or agreed to in writing, this
##    software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.
##

import
  argtable3/argtable3, driver/i2c, esp_console, esp_log

const
  I2C_MASTER_TX_BUF_DISABLE* = 0
  I2C_MASTER_RX_BUF_DISABLE* = 0
  WRITE_BIT* = I2C_MASTER_WRITE
  READ_BIT* = I2C_MASTER_READ
  ACK_CHECK_EN* = 0x00000001
  ACK_CHECK_DIS* = 0x00000000
  ACK_VAL* = 0x00000000
  NACK_VAL* = 0x00000001

var TAG*: cstring = "cmd_i2ctools"

var i2c_gpio_sda*: gpio_num_t = 18

var i2c_gpio_scl*: gpio_num_t = 19

var i2c_frequency*: uint32_t = 100000

var i2c_port*: i2c_port_t = I2C_NUM_0

proc i2c_get_port*(port: cint; i2c_port: ptr i2c_port_t): esp_err_t {.cdecl.} =
  if port >= I2C_NUM_MAX:
    ESP_LOGE(TAG, "Wrong port number: %d", port)
    return ESP_FAIL
  case port
  of 0:
    i2c_port[] = I2C_NUM_0
  of 1:
    i2c_port[] = I2C_NUM_1
  else:
    i2c_port[] = I2C_NUM_0
  return ESP_OK

proc i2c_master_driver_initialize*(): esp_err_t {.cdecl.} =
  var conf: i2c_config_t
  conf.mode = I2C_MODE_MASTER
  conf.sda_io_num = i2c_gpio_sda
  conf.sda_pullup_en = GPIO_PULLUP_ENABLE
  conf.scl_io_num = i2c_gpio_scl
  conf.scl_pullup_en = GPIO_PULLUP_ENABLE
  conf.master.clk_speed = i2c_frequency
  return i2c_param_config(i2c_port, addr(conf))

var i2cconfig_args*: tuple[port: ptr arg_int, freq: ptr arg_int, sda: ptr arg_int,
                         scl: ptr arg_int, `end`: ptr arg_end]

proc do_i2cconfig_cmd*(argc: cint; argv: cstringArray): cint {.cdecl.} =
  var nerrors: cint = arg_parse(argc, argv, cast[ptr pointer](addr(i2cconfig_args)))
  if nerrors != 0:
    arg_print_errors(stderr, i2cconfig_args.`end`, argv[0])
    return 0
  if i2cconfig_args.port.count:
    if i2c_get_port(i2cconfig_args.port.ival[0], addr(i2c_port)) != ESP_OK:
      return 1
  if i2cconfig_args.freq.count:
    i2c_frequency = i2cconfig_args.freq.ival[0]
  i2c_gpio_sda = i2cconfig_args.sda.ival[0]
  ##  Check "--scl" option
  i2c_gpio_scl = i2cconfig_args.scl.ival[0]
  return 0

proc register_i2cconfig*() {.cdecl.} =
  i2cconfig_args.port = arg_int0(nil, "port", "<0|1>", "Set the I2C bus port number")
  i2cconfig_args.freq = arg_int0(nil, "freq", "<Hz>",
                               "Set the frequency(Hz) of I2C bus")
  i2cconfig_args.sda = arg_int1(nil, "sda", "<gpio>", "Set the gpio for I2C SDA")
  i2cconfig_args.scl = arg_int1(nil, "scl", "<gpio>", "Set the gpio for I2C SCL")
  i2cconfig_args.`end` = arg_end(2)
  var i2cconfig_cmd: esp_console_cmd_t
  i2cconfig_cmd.command = "i2cconfig"
  i2cconfig_cmd.help = "Config I2C bus"
  i2cconfig_cmd.hint = nil
  i2cconfig_cmd.`func` = addr(do_i2cconfig_cmd)
  i2cconfig_cmd.argtable = addr(i2cconfig_args)
  ESP_ERROR_CHECK(esp_console_cmd_register(addr(i2cconfig_cmd)))

proc do_i2cdetect_cmd*(argc: cint; argv: cstringArray): cint {.cdecl.} =
  i2c_driver_install(i2c_port, I2C_MODE_MASTER, I2C_MASTER_RX_BUF_DISABLE,
                     I2C_MASTER_TX_BUF_DISABLE, 0)
  i2c_master_driver_initialize()
  var address: uint8_t
  printf("     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f\c\n")
  var i: cint = 0
  while i < 128:
    printf("%02x: ", i)
    var j: cint = 0
    while j < 16:
      fflush(stdout)
      address = i + j
      var cmd: i2c_cmd_handle_t = i2c_cmd_link_create()
      i2c_master_start(cmd)
      i2c_master_write_byte(cmd, (address shl 1) or WRITE_BIT, ACK_CHECK_EN)
      i2c_master_stop(cmd)
      var ret: esp_err_t = i2c_master_cmd_begin(i2c_port, cmd, 50 div
          portTICK_RATE_MS)
      i2c_cmd_link_delete(cmd)
      if ret == ESP_OK:
        printf("%02x ", address)
      elif ret == ESP_ERR_TIMEOUT:
        printf("UU ")
      else:
        printf("-- ")
      inc(j)
    printf("\c\n")
    inc(i, 16)
  i2c_driver_delete(i2c_port)
  return 0

proc register_i2cdectect*() {.cdecl.} =
  var i2cdetect_cmd: esp_console_cmd_t
  i2cdetect_cmd.command = "i2cdetect"
  i2cdetect_cmd.help = "Scan I2C bus for devices"
  i2cdetect_cmd.hint = nil
  i2cdetect_cmd.`func` = addr(do_i2cdetect_cmd)
  i2cdetect_cmd.argtable = nil
  ESP_ERROR_CHECK(esp_console_cmd_register(addr(i2cdetect_cmd)))

var i2cget_args*: tuple[chip_address: ptr arg_int, register_address: ptr arg_int,
                      data_length: ptr arg_int, `end`: ptr arg_end]

proc do_i2cget_cmd*(argc: cint; argv: cstringArray): cint {.cdecl.} =
  var nerrors: cint = arg_parse(argc, argv, cast[ptr pointer](addr(i2cget_args)))
  if nerrors != 0:
    arg_print_errors(stderr, i2cget_args.`end`, argv[0])
    return 0
  var chip_addr: cint = i2cget_args.chip_address.ival[0]
  ##  Check register address: "-r" option
  var data_addr: cint = -1
  if i2cget_args.register_address.count:
    data_addr = i2cget_args.register_address.ival[0]
  var len: cint = 1
  if i2cget_args.data_length.count:
    len = i2cget_args.data_length.ival[0]
  var data: ptr uint8_t = malloc(len)
  i2c_driver_install(i2c_port, I2C_MODE_MASTER, I2C_MASTER_RX_BUF_DISABLE,
                     I2C_MASTER_TX_BUF_DISABLE, 0)
  i2c_master_driver_initialize()
  var cmd: i2c_cmd_handle_t = i2c_cmd_link_create()
  i2c_master_start(cmd)
  if data_addr != -1:
    i2c_master_write_byte(cmd, chip_addr shl 1 or WRITE_BIT, ACK_CHECK_EN)
    i2c_master_write_byte(cmd, data_addr, ACK_CHECK_EN)
    i2c_master_start(cmd)
  i2c_master_write_byte(cmd, chip_addr shl 1 or READ_BIT, ACK_CHECK_EN)
  if len > 1:
    i2c_master_read(cmd, data, len - 1, ACK_VAL)
  i2c_master_read_byte(cmd, data + len - 1, NACK_VAL)
  i2c_master_stop(cmd)
  var ret: esp_err_t = i2c_master_cmd_begin(i2c_port, cmd, 1000 div portTICK_RATE_MS)
  i2c_cmd_link_delete(cmd)
  if ret == ESP_OK:
    var i: cint = 0
    while i < len:
      printf("0x%02x ", data[i])
      if (i + 1) mod 16 == 0:
        printf("\c\n")
      inc(i)
    if len mod 16:
      printf("\c\n")
  elif ret == ESP_ERR_TIMEOUT:
    ESP_LOGW(TAG, "Bus is busy")
  else:
    ESP_LOGW(TAG, "Read failed")
  free(data)
  i2c_driver_delete(i2c_port)
  return 0

proc register_i2cget*() {.cdecl.} =
  i2cget_args.chip_address = arg_int1("c", "chip", "<chip_addr>", "Specify the address of the chip on that bus")
  i2cget_args.register_address = arg_int0("r", "register", "<register_addr>", "Specify the address on that chip to read from")
  i2cget_args.data_length = arg_int0("l", "length", "<length>", "Specify the length to read from that data address")
  i2cget_args.`end` = arg_end(1)
  var i2cget_cmd: esp_console_cmd_t
  i2cget_cmd.command = "i2cget"
  i2cget_cmd.help = "Read registers visible through the I2C bus"
  i2cget_cmd.hint = nil
  i2cget_cmd.`func` = addr(do_i2cget_cmd)
  i2cget_cmd.argtable = addr(i2cget_args)
  ESP_ERROR_CHECK(esp_console_cmd_register(addr(i2cget_cmd)))

var i2cset_args*: tuple[chip_address: ptr arg_int, register_address: ptr arg_int,
                      data: ptr arg_int, `end`: ptr arg_end]

proc do_i2cset_cmd*(argc: cint; argv: cstringArray): cint {.cdecl.} =
  var nerrors: cint = arg_parse(argc, argv, cast[ptr pointer](addr(i2cset_args)))
  if nerrors != 0:
    arg_print_errors(stderr, i2cset_args.`end`, argv[0])
    return 0
  var chip_addr: cint = i2cset_args.chip_address.ival[0]
  ##  Check register address: "-r" option
  var data_addr: cint = 0
  if i2cset_args.register_address.count:
    data_addr = i2cset_args.register_address.ival[0]
  var len: cint = i2cset_args.data.count
  i2c_driver_install(i2c_port, I2C_MODE_MASTER, I2C_MASTER_RX_BUF_DISABLE,
                     I2C_MASTER_TX_BUF_DISABLE, 0)
  i2c_master_driver_initialize()
  var cmd: i2c_cmd_handle_t = i2c_cmd_link_create()
  i2c_master_start(cmd)
  i2c_master_write_byte(cmd, chip_addr shl 1 or WRITE_BIT, ACK_CHECK_EN)
  if i2cset_args.register_address.count:
    i2c_master_write_byte(cmd, data_addr, ACK_CHECK_EN)
  var i: cint = 0
  while i < len:
    i2c_master_write_byte(cmd, i2cset_args.data.ival[i], ACK_CHECK_EN)
    inc(i)
  i2c_master_stop(cmd)
  var ret: esp_err_t = i2c_master_cmd_begin(i2c_port, cmd, 1000 div portTICK_RATE_MS)
  i2c_cmd_link_delete(cmd)
  if ret == ESP_OK:
    ESP_LOGI(TAG, "Write OK")
  elif ret == ESP_ERR_TIMEOUT:
    ESP_LOGW(TAG, "Bus is busy")
  else:
    ESP_LOGW(TAG, "Write Failed")
  i2c_driver_delete(i2c_port)
  return 0

proc register_i2cset*() {.cdecl.} =
  i2cset_args.chip_address = arg_int1("c", "chip", "<chip_addr>", "Specify the address of the chip on that bus")
  i2cset_args.register_address = arg_int0("r", "register", "<register_addr>", "Specify the address on that chip to read from")
  i2cset_args.data = arg_intn(nil, nil, "<data>", 0, 256,
                            "Specify the data to write to that data address")
  i2cset_args.`end` = arg_end(2)
  var i2cset_cmd: esp_console_cmd_t
  i2cset_cmd.command = "i2cset"
  i2cset_cmd.help = "Set registers visible through the I2C bus"
  i2cset_cmd.hint = nil
  i2cset_cmd.`func` = addr(do_i2cset_cmd)
  i2cset_cmd.argtable = addr(i2cset_args)
  ESP_ERROR_CHECK(esp_console_cmd_register(addr(i2cset_cmd)))

var i2cdump_args*: tuple[chip_address: ptr arg_int, size: ptr arg_int,
                       `end`: ptr arg_end]

proc do_i2cdump_cmd*(argc: cint; argv: cstringArray): cint {.cdecl.} =
  var nerrors: cint = arg_parse(argc, argv, cast[ptr pointer](addr(i2cdump_args)))
  if nerrors != 0:
    arg_print_errors(stderr, i2cdump_args.`end`, argv[0])
    return 0
  var chip_addr: cint = i2cdump_args.chip_address.ival[0]
  ##  Check read size: "-s" option
  var size: cint = 1
  if i2cdump_args.size.count:
    size = i2cdump_args.size.ival[0]
  if size != 1 and size != 2 and size != 4:
    ESP_LOGE(TAG, "Wrong read size. Only support 1,2,4")
    return 1
  i2c_driver_install(i2c_port, I2C_MODE_MASTER, I2C_MASTER_RX_BUF_DISABLE,
                     I2C_MASTER_TX_BUF_DISABLE, 0)
  i2c_master_driver_initialize()
  var data_addr: uint8_t
  var data: array[4, uint8_t]
  var `block`: array[16, int32_t]
  printf("     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f    0123456789abcdef\c\n")
  var i: cint = 0
  while i < 128:
    printf("%02x: ", i)
    var j: cint = 0
    while j < 16:
      fflush(stdout)
      data_addr = i + j
      var cmd: i2c_cmd_handle_t = i2c_cmd_link_create()
      i2c_master_start(cmd)
      i2c_master_write_byte(cmd, chip_addr shl 1 or WRITE_BIT, ACK_CHECK_EN)
      i2c_master_write_byte(cmd, data_addr, ACK_CHECK_EN)
      i2c_master_start(cmd)
      i2c_master_write_byte(cmd, chip_addr shl 1 or READ_BIT, ACK_CHECK_EN)
      if size > 1:
        i2c_master_read(cmd, data, size - 1, ACK_VAL)
      i2c_master_read_byte(cmd, data + size - 1, NACK_VAL)
      i2c_master_stop(cmd)
      var ret: esp_err_t = i2c_master_cmd_begin(i2c_port, cmd, 50 div
          portTICK_RATE_MS)
      i2c_cmd_link_delete(cmd)
      if ret == ESP_OK:
        var k: cint = 0
        while k < size:
          printf("%02x ", data[k])
          `block`[j + k] = data[k]
          inc(k)
      else:
        var k: cint = 0
        while k < size:
          printf("XX ")
          `block`[j + k] = -1
          inc(k)
      inc(j, size)
    printf("   ")
    var k: cint = 0
    while k < 16:
      if `block`[k] < 0:
        printf("X")
      if (`block`[k] and 0x000000FF) == 0x00000000 or
          (`block`[k] and 0x000000FF) == 0x000000FF:
        printf(".")
      elif (`block`[k] and 0x000000FF) < 32 or (`block`[k] and 0x000000FF) >= 127:
        printf("?")
      else:
        printf("%c", `block`[k] and 0x000000FF)
      inc(k)
    printf("\c\n")
    inc(i, 16)
  i2c_driver_delete(i2c_port)
  return 0

proc register_i2cdump*() {.cdecl.} =
  i2cdump_args.chip_address = arg_int1("c", "chip", "<chip_addr>", "Specify the address of the chip on that bus")
  i2cdump_args.size = arg_int0("s", "size", "<size>", "Specify the size of each read")
  i2cdump_args.`end` = arg_end(1)
  var i2cdump_cmd: esp_console_cmd_t
  i2cdump_cmd.command = "i2cdump"
  i2cdump_cmd.help = "Examine registers visible through the I2C bus"
  i2cdump_cmd.hint = nil
  i2cdump_cmd.`func` = addr(do_i2cdump_cmd)
  i2cdump_cmd.argtable = addr(i2cdump_args)
  ESP_ERROR_CHECK(esp_console_cmd_register(addr(i2cdump_cmd)))

proc register_i2ctools*() {.cdecl.} =
  register_i2cconfig()
  register_i2cdectect()
  register_i2cget()
  register_i2cset()
  register_i2cdump()

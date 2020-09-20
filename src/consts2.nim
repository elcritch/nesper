type
  esp_err_t* = int32

##  Definitions for error constants.

const
  ESP_OK* = 0
  ESP_FAIL* = -1
  ESP_ERR_NO_MEM* = 0x00000101
  ESP_ERR_INVALID_ARG* = 0x00000102
  ESP_ERR_INVALID_STATE* = 0x00000103
  ESP_ERR_INVALID_SIZE* = 0x00000104
  ESP_ERR_NOT_FOUND* = 0x00000105
  ESP_ERR_NOT_SUPPORTED* = 0x00000106
  ESP_ERR_TIMEOUT* = 0x00000107
  ESP_ERR_INVALID_RESPONSE* = 0x00000108
  ESP_ERR_INVALID_CRC* = 0x00000109
  ESP_ERR_INVALID_VERSION* = 0x0000010A
  ESP_ERR_INVALID_MAC* = 0x0000010B
  ESP_ERR_WIFI_BASE* = 0x00003000
  ESP_ERR_MESH_BASE* = 0x00004000
  ESP_ERR_FLASH_BASE* = 0x00006000

##  This is used to provide SystemView with positive IRQ IDs, otherwise sheduler events are not shown properly
##  #define ETS_INTERNAL_INTR_SOURCE_OFF		(-ETS_INTERNAL_PROFILING_INTR_SOURCE)

template ESP_INTR_ENABLE*(inum: untyped): untyped =
  xt_ints_on((1 shl inum))

template ESP_INTR_DISABLE*(inum: untyped): untyped =
  xt_ints_off((1 shl inum))

proc esp_err_to_name*(code: esp_err_t): cstring {.cdecl, importc: "esp_err_to_name",
    header: "freertos/FreeRTOS.h".}
proc esp_err_to_name_r*(code: esp_err_t; buf: cstring; buflen: csize): cstring {.cdecl,
    importc: "esp_err_to_name_r", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK*(x: cint) {.cdecl, importc: "ESP_ERROR_CHECK", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK_WITHOUT_ABORT*(x: cint) {.cdecl,
    importc: "ESP_ERROR_CHECK_WITHOUT_ABORT", header: "freertos/FreeRTOS.h".}
type
  INNER_C_UNION_consts_47* {.importc: "no_name", header: "freertos/FreeRTOS.h", bycopy.} = object {.
      union.}
    pvDummy2* {.importc: "pvDummy2".}: pointer
    uxDummy2* {.importc: "uxDummy2".}: UBaseType_t

  TickType_t* = uint32
  StaticQueue_t* {.importc: "StaticQueue_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    pvDummy1* {.importc: "pvDummy1".}: array[3, pointer]
    u* {.importc: "u".}: INNER_C_UNION_consts_47
    xDummy3* {.importc: "xDummy3".}: array[2, StaticList_t]
    uxDummy4* {.importc: "uxDummy4".}: array[3, UBaseType_t]
    ucDummy6* {.importc: "ucDummy6".}: uint8_t
    pvDummy7* {.importc: "pvDummy7".}: pointer
    uxDummy8* {.importc: "uxDummy8".}: UBaseType_t
    ucDummy9* {.importc: "ucDummy9".}: uint8_t
    muxDummy* {.importc: "muxDummy".}: portMUX_TYPE ## Mutex required due to SMP

  StaticSemaphore_t* = StaticQueue_t
  portCHAR* = int8
  portFLOAT* = cfloat
  portDOUBLE* = cdouble
  portLONG* = int32
  portSHORT* = int16
  portSTACK_TYPE* = uint8
  portBASE_TYPE* = cint
  StackType_t* = portSTACK_TYPE
  BaseType_t* = portBASE_TYPE
  UBaseType_t* = portBASE_TYPE
  intr_handler_t* = proc (arg: pointer) {.cdecl.}
  shared_vector_desc_t* {.importc: "shared_vector_desc_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    disabled* {.importc: "disabled".}: cint ##  int disabled: 1;
                                        ##  int source: 8;
    source* {.importc: "source".}: cint
    statusreg* {.importc: "statusreg".}: ptr uint32
    statusmask* {.importc: "statusmask".}: uint32
    isr* {.importc: "isr".}: intr_handler_t
    arg* {.importc: "arg".}: pointer
    next* {.importc: "next".}: ptr shared_vector_desc_t


## Pack using bitfields for better memory use

type
  vector_desc_t* {.importc: "vector_desc_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    flags* {.importc: "flags".}: cint ##  int flags: 16;                          //OR of VECDESC_FLAG_* defines
                                  ##  unsigned int cpu: 1;
                                  ##  unsigned int intno: 5;
                                  ##  int source: 8;                          //Interrupt mux flags, used when not shared
    ## OR of VECDESC_FLAG_* defines
    cpu* {.importc: "cpu".}: cuint
    intno* {.importc: "intno".}: cuint
    source* {.importc: "source".}: cint ## Interrupt mux flags, used when not shared
    shared_vec_info* {.importc: "shared_vec_info".}: ptr shared_vector_desc_t ## used when VECDESC_FL_SHARED
    next* {.importc: "next".}: ptr vector_desc_t

  intr_handle_data_t* {.importc: "intr_handle_data_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    vector_desc* {.importc: "vector_desc".}: ptr vector_desc_t
    shared_vector_desc* {.importc: "shared_vector_desc".}: ptr shared_vector_desc_t

  intr_handle_t* = ptr intr_handle_data_t

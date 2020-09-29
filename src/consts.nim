
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

type
  TickType_t* = uint32
#   INNER_C_UNION_consts_39* {.importcpp: "no_name", header: "freertos/FreeRTOS.h", bycopy.} = object {.
#       union.}
#     pvDummy2* {.importc: "pvDummy2".}: pointer
#     uxDummy2* {.importc: "uxDummy2".}: UBaseType_t

#   StaticSemaphore_t* = StaticQueue_t
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
  shared_vector_desc_t* {.importcpp: "shared_vector_desc_t", header: "freertos/FreeRTOS.h",
                         bycopy.} = object ##  int disabled: 1;
                                        ##  int source: 8;
    disabled* {.importc: "disabled".}: cint
    source* {.importc: "source".}: cint
    statusreg* {.importc: "statusreg".}: ptr uint32
    statusmask* {.importc: "statusmask".}: uint32
    isr* {.importc: "isr".}: intr_handler_t
    arg* {.importc: "arg".}: pointer
    next* {.importc: "next".}: ptr shared_vector_desc_t


## Pack using bitfields for better memory use

type
  vector_desc_t* {.importcpp: "vector_desc_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    ##  int flags: 16;                          //OR of VECDESC_FLAG_* defines
    ##  unsigned int cpu: 1;
    ##  unsigned int intno: 5;
    ##  int source: 8;                          //Interrupt mux flags, used when not shared
    flags* {.importc: "flags".}: cint ## OR of VECDESC_FLAG_* defines
    cpu* {.importc: "cpu".}: cuint
    intno* {.importc: "intno".}: cuint
    source* {.importc: "source".}: cint ## Interrupt mux flags, used when not shared
    shared_vec_info* {.importc: "shared_vec_info".}: ptr shared_vector_desc_t ## used when VECDESC_FL_SHARED
    next* {.importc: "next".}: ptr vector_desc_t

  intr_handle_data_t* {.importcpp: "intr_handle_data_t", header: "freertos/FreeRTOS.h", bycopy.} = object
    vector_desc* {.importc: "vector_desc".}: ptr vector_desc_t
    shared_vector_desc* {.importc: "shared_vector_desc".}: ptr shared_vector_desc_t

  intr_handle_t* = ptr intr_handle_data_t

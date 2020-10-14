
import ../../consts

type
  gpio_num_t* {.size: sizeof(cint).} = enum
    GPIO_NUM_NC = -1,           ## !< Use to signal not connected to S/W
    GPIO_NUM_0 = 0,             ## !< GPIO0, input and output
    GPIO_NUM_1 = 1,             ## !< GPIO1, input and output
    GPIO_NUM_2 = 2, ## !< GPIO2, input and output
                 ##                              @note There are more enumerations like that
                 ##                              up to GPIO39, excluding GPIO20, GPIO24 and GPIO28..31.
                 ##                              They are not shown here to reduce redundant information.
                 ##                              @note GPIO34..39 are input mode only.
                 ## * @cond
    GPIO_NUM_3 = 3,             ## !< GPIO3, input and output
    GPIO_NUM_4 = 4,             ## !< GPIO4, input and output
    GPIO_NUM_5 = 5,             ## !< GPIO5, input and output
    GPIO_NUM_6 = 6,             ## !< GPIO6, input and output
    GPIO_NUM_7 = 7,             ## !< GPIO7, input and output
    GPIO_NUM_8 = 8,             ## !< GPIO8, input and output
    GPIO_NUM_9 = 9,             ## !< GPIO9, input and output
    GPIO_NUM_10 = 10,           ## !< GPIO10, input and output
    GPIO_NUM_11 = 11,           ## !< GPIO11, input and output
    GPIO_NUM_12 = 12,           ## !< GPIO12, input and output
    GPIO_NUM_13 = 13,           ## !< GPIO13, input and output
    GPIO_NUM_14 = 14,           ## !< GPIO14, input and output
    GPIO_NUM_15 = 15,           ## !< GPIO15, input and output
    GPIO_NUM_16 = 16,           ## !< GPIO16, input and output
    GPIO_NUM_17 = 17,           ## !< GPIO17, input and output
    GPIO_NUM_18 = 18,           ## !< GPIO18, input and output
    GPIO_NUM_19 = 19,           ## !< GPIO19, input and output
    GPIO_NUM_21 = 21,           ## !< GPIO21, input and output
    GPIO_NUM_22 = 22,           ## !< GPIO22, input and output
    GPIO_NUM_23 = 23,           ## !< GPIO23, input and output
    GPIO_NUM_25 = 25,           ## !< GPIO25, input and output
    GPIO_NUM_26 = 26,           ## !< GPIO26, input and output
    GPIO_NUM_27 = 27,           ## !< GPIO27, input and output
    GPIO_NUM_32 = 32,           ## !< GPIO32, input and output
    GPIO_NUM_33 = 33,           ## !< GPIO33, input and output
    GPIO_NUM_34 = 34,           ## !< GPIO34, input mode only
    GPIO_NUM_35 = 35,           ## !< GPIO35, input mode only
    GPIO_NUM_36 = 36,           ## !< GPIO36, input mode only
    GPIO_NUM_37 = 37,           ## !< GPIO37, input mode only
    GPIO_NUM_38 = 38,           ## !< GPIO38, input mode only
    GPIO_NUM_39 = 39,           ## !< GPIO39, input mode only
    GPIO_NUM_MAX = 40           ## * @endcond

const
  GPIO_SEL_0* = (BIT(0))        ## !< Pin 0 selected
  GPIO_SEL_1* = (BIT(1))        ## !< Pin 1 selected
  GPIO_SEL_2* = (BIT(2)) ## !< Pin 2 selected
  GPIO_SEL_3* = (BIT(3))        ## !< Pin 3 selected
  GPIO_SEL_4* = (BIT(4))        ## !< Pin 4 selected
  GPIO_SEL_5* = (BIT(5))        ## !< Pin 5 selected
  GPIO_SEL_6* = (BIT(6))        ## !< Pin 6 selected
  GPIO_SEL_7* = (BIT(7))        ## !< Pin 7 selected
  GPIO_SEL_8* = (BIT(8))        ## !< Pin 8 selected
  GPIO_SEL_9* = (BIT(9))        ## !< Pin 9 selected
  GPIO_SEL_10* = (BIT(10))      ## !< Pin 10 selected
  GPIO_SEL_11* = (BIT(11))      ## !< Pin 11 selected
  GPIO_SEL_12* = (BIT(12))      ## !< Pin 12 selected
  GPIO_SEL_13* = (BIT(13))      ## !< Pin 13 selected
  GPIO_SEL_14* = (BIT(14))      ## !< Pin 14 selected
  GPIO_SEL_15* = (BIT(15))      ## !< Pin 15 selected
  GPIO_SEL_16* = (BIT(16))      ## !< Pin 16 selected
  GPIO_SEL_17* = (BIT(17))      ## !< Pin 17 selected
  GPIO_SEL_18* = (BIT(18))      ## !< Pin 18 selected
  GPIO_SEL_19* = (BIT(19))      ## !< Pin 19 selected
  GPIO_SEL_21* = (BIT(21))      ## !< Pin 21 selected
  GPIO_SEL_22* = (BIT(22))      ## !< Pin 22 selected
  GPIO_SEL_23* = (BIT(23))      ## !< Pin 23 selected
  GPIO_SEL_25* = (BIT(25))      ## !< Pin 25 selected
  GPIO_SEL_26* = (BIT(26))      ## !< Pin 26 selected
  GPIO_SEL_27* = (BIT(27))      ## !< Pin 27 selected
  GPIO_SEL_32* = ((uint64)((cast[uint64](1)) shl 32)) ## !< Pin 32 selected
  GPIO_SEL_33* = ((uint64)((cast[uint64](1)) shl 33)) ## !< Pin 33 selected
  GPIO_SEL_34* = ((uint64)((cast[uint64](1)) shl 34)) ## !< Pin 34 selected
  GPIO_SEL_35* = ((uint64)((cast[uint64](1)) shl 35)) ## !< Pin 35 selected
  GPIO_SEL_36* = ((uint64)((cast[uint64](1)) shl 36)) ## !< Pin 36 selected
  GPIO_SEL_37* = ((uint64)((cast[uint64](1)) shl 37)) ## !< Pin 37 selected
  GPIO_SEL_38* = ((uint64)((cast[uint64](1)) shl 38)) ## !< Pin 38 selected
  GPIO_SEL_39* = ((uint64)((cast[uint64](1)) shl 39)) ## !< Pin 39 selected

##  Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

const tgs_header = """#include "soc/timer_group_struct.h"
                      #include "soc/timer_group_reg.h" """
type
  INNER_C_STRUCT_timer_group_struct_26* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 10.}: uint32
    alarm_en* {.importc: "alarm_en", bitsize: 1.}: uint32 ## When set  alarm is enabled
    level_int_en* {.importc: "level_int_en", bitsize: 1.}: uint32 ## When set  level type interrupt will be generated during alarm
    edge_int_en* {.importc: "edge_int_en", bitsize: 1.}: uint32 ## When set  edge type interrupt will be generated during alarm
    divider* {.importc: "divider", bitsize: 16.}: uint32 ## Timer clock (T0/1_clk) pre-scale value.
    autoreload* {.importc: "autoreload", bitsize: 1.}: uint32 ## When set  timer 0/1 auto-reload at alarming is enabled
    increase* {.importc: "increase", bitsize: 1.}: uint32 ## When set  timer 0/1 time-base counter increment. When cleared timer 0 time-base counter decrement.
    enable* {.importc: "enable", bitsize: 1.}: uint32 ## When set  timer 0/1 time-base counter is enabled

  INNER_C_STRUCT_timer_group_struct_25* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    config* {.importc: "config".}: INNER_C_STRUCT_timer_group_struct_26
    cnt_low* {.importc: "cnt_low".}: uint32 ## Register to store timer 0/1 time-base counter current value lower 32 bits.
    cnt_high* {.importc: "cnt_high".}: uint32 ## Register to store timer 0 time-base counter current value higher 32 bits.
    update* {.importc: "update".}: uint32 ## Write any value will trigger a timer 0 time-base counter value update (timer 0 current value will be stored in registers above)
    alarm_low* {.importc: "alarm_low".}: uint32 ## Timer 0 time-base counter value lower 32 bits that will trigger the alarm
    alarm_high* {.importc: "alarm_high".}: uint32 ## Timer 0 time-base counter value higher 32 bits that will trigger the alarm
    load_low* {.importc: "load_low".}: uint32 ## Lower 32 bits of the value that will load into timer 0 time-base counter
    load_high* {.importc: "load_high".}: uint32 ## higher 32 bits of the value that will load into timer 0 time-base counter
    reload* {.importc: "reload".}: uint32 ## Write any value will trigger timer 0 time-base counter reload

  INNER_C_STRUCT_timer_group_struct_45* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 14.}: uint32
    flashboot_mod_en* {.importc: "flashboot_mod_en", bitsize: 1.}: uint32 ## When set  flash boot protection is enabled
    sys_reset_length* {.importc: "sys_reset_length", bitsize: 3.}: uint32 ## length of system reset selection. 0: 100ns  1: 200ns  2: 300ns  3: 400ns  4: 500ns  5: 800ns  6: 1.6us  7: 3.2us
    cpu_reset_length* {.importc: "cpu_reset_length", bitsize: 3.}: uint32 ## length of CPU reset selection. 0: 100ns  1: 200ns  2: 300ns  3: 400ns  4: 500ns  5: 800ns  6: 1.6us  7: 3.2us
    level_int_en* {.importc: "level_int_en", bitsize: 1.}: uint32 ## When set  level type interrupt generation is enabled
    edge_int_en* {.importc: "edge_int_en", bitsize: 1.}: uint32 ## When set  edge type interrupt generation is enabled
    stg3* {.importc: "stg3", bitsize: 2.}: uint32 ## Stage 3 configuration. 0: off  1: interrupt  2: reset CPU  3: reset system
    stg2* {.importc: "stg2", bitsize: 2.}: uint32 ## Stage 2 configuration. 0: off  1: interrupt  2: reset CPU  3: reset system
    stg1* {.importc: "stg1", bitsize: 2.}: uint32 ## Stage 1 configuration. 0: off  1: interrupt  2: reset CPU  3: reset system
    stg0* {.importc: "stg0", bitsize: 2.}: uint32 ## Stage 0 configuration. 0: off  1: interrupt  2: reset CPU  3: reset system
    en* {.importc: "en", bitsize: 1.}: uint32 ## When set  SWDT is enabled

  INNER_C_STRUCT_timer_group_struct_58* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 16.}: uint32
    clk_prescale* {.importc: "clk_prescale", bitsize: 16.}: uint32 ## SWDT clock prescale value. Period = 12.5ns * value stored in this register

  INNER_C_STRUCT_timer_group_struct_68* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 12.}: uint32
    start_cycling* {.importc: "start_cycling", bitsize: 1.}: uint32
    clk_sel* {.importc: "clk_sel", bitsize: 2.}: uint32
    rdy* {.importc: "rdy", bitsize: 1.}: uint32
    max* {.importc: "max", bitsize: 15.}: uint32
    start* {.importc: "start", bitsize: 1.}: uint32

  INNER_C_STRUCT_timer_group_struct_76* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 7.}: uint32
    value* {.importc: "value", bitsize: 25.}: uint32

  INNER_C_STRUCT_timer_group_struct_80* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 7.}: uint32
    rtc_only* {.importc: "rtc_only", bitsize: 1.}: uint32
    cpst_en* {.importc: "cpst_en", bitsize: 1.}: uint32
    lac_en* {.importc: "lac_en", bitsize: 1.}: uint32
    alarm_en* {.importc: "alarm_en", bitsize: 1.}: uint32
    level_int_en* {.importc: "level_int_en", bitsize: 1.}: uint32
    edge_int_en* {.importc: "edge_int_en", bitsize: 1.}: uint32
    divider* {.importc: "divider", bitsize: 16.}: uint32
    autoreload* {.importc: "autoreload", bitsize: 1.}: uint32
    increase* {.importc: "increase", bitsize: 1.}: uint32
    en* {.importc: "en", bitsize: 1.}: uint32

  INNER_C_STRUCT_timer_group_struct_93* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 6.}: uint32
    step_len* {.importc: "step_len", bitsize: 26.}: uint32

  INNER_C_STRUCT_timer_group_struct_105* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    t0* {.importc: "t0", bitsize: 1.}: uint32 ## interrupt when timer0 alarm
    t1* {.importc: "t1", bitsize: 1.}: uint32 ## interrupt when timer1 alarm
    wdt* {.importc: "wdt", bitsize: 1.}: uint32 ## Interrupt when an interrupt stage timeout
    lact* {.importc: "lact", bitsize: 1.}: uint32
    reserved4* {.importc: "reserved4", bitsize: 28.}: uint32

  INNER_C_STRUCT_timer_group_struct_112* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    t0* {.importc: "t0", bitsize: 1.}: uint32 ## interrupt when timer0 alarm
    t1* {.importc: "t1", bitsize: 1.}: uint32 ## interrupt when timer1 alarm
    wdt* {.importc: "wdt", bitsize: 1.}: uint32 ## Interrupt when an interrupt stage timeout
    lact* {.importc: "lact", bitsize: 1.}: uint32
    reserved4* {.importc: "reserved4", bitsize: 28.}: uint32

  INNER_C_STRUCT_timer_group_struct_119* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    t0* {.importc: "t0", bitsize: 1.}: uint32 ## interrupt when timer0 alarm
    t1* {.importc: "t1", bitsize: 1.}: uint32 ## interrupt when timer1 alarm
    wdt* {.importc: "wdt", bitsize: 1.}: uint32 ## Interrupt when an interrupt stage timeout
    lact* {.importc: "lact", bitsize: 1.}: uint32
    reserved4* {.importc: "reserved4", bitsize: 28.}: uint32

  INNER_C_STRUCT_timer_group_struct_126* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    t0* {.importc: "t0", bitsize: 1.}: uint32 ## interrupt when timer0 alarm
    t1* {.importc: "t1", bitsize: 1.}: uint32 ## interrupt when timer1 alarm
    wdt* {.importc: "wdt", bitsize: 1.}: uint32 ## Interrupt when an interrupt stage timeout
    lact* {.importc: "lact", bitsize: 1.}: uint32
    reserved4* {.importc: "reserved4", bitsize: 28.}: uint32

  INNER_C_STRUCT_timer_group_struct_153* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    date* {.importc: "date", bitsize: 28.}: uint32 ## Version of this regfile
    reserved28* {.importc: "reserved28", bitsize: 4.}: uint32

  INNER_C_STRUCT_timer_group_struct_157* {.importc: "no_name",
      header: tgs_header, bycopy.} = object
    reserved0* {.importc: "reserved0", bitsize: 31.}: uint32
    en* {.importc: "en", bitsize: 1.}: uint32 ## Force clock enable for this regfile

  timg_dev_t* {.importc: "timg_dev_t", header: tgs_header, bycopy.} = object
    hw_timer* {.importc: "hw_timer".}: array[2, INNER_C_STRUCT_timer_group_struct_25]
    wdt_config0* {.importc: "wdt_config0".}: INNER_C_STRUCT_timer_group_struct_45
    wdt_config1* {.importc: "wdt_config1".}: INNER_C_STRUCT_timer_group_struct_58
    wdt_config2* {.importc: "wdt_config2".}: uint32 ## Stage 0 timeout value in SWDT clock cycles
    wdt_config3* {.importc: "wdt_config3".}: uint32 ## Stage 1 timeout value in SWDT clock cycles
    wdt_config4* {.importc: "wdt_config4".}: uint32 ## Stage 2 timeout value in SWDT clock cycles
    wdt_config5* {.importc: "wdt_config5".}: uint32 ## Stage 3 timeout value in SWDT clock cycles
    wdt_feed* {.importc: "wdt_feed".}: uint32 ## Write any value will feed SWDT
    wdt_wprotect* {.importc: "wdt_wprotect".}: uint32 ## If change its value from default  then write protection is on.
    rtc_cali_cfg* {.importc: "rtc_cali_cfg".}: INNER_C_STRUCT_timer_group_struct_68
    rtc_cali_cfg1* {.importc: "rtc_cali_cfg1".}: INNER_C_STRUCT_timer_group_struct_76
    lactconfig* {.importc: "lactconfig".}: INNER_C_STRUCT_timer_group_struct_80
    lactrtc* {.importc: "lactrtc".}: INNER_C_STRUCT_timer_group_struct_93
    lactlo* {.importc: "lactlo".}: uint32
    lacthi* {.importc: "lacthi".}: uint32
    lactupdate* {.importc: "lactupdate".}: uint32
    lactalarmlo* {.importc: "lactalarmlo".}: uint32
    lactalarmhi* {.importc: "lactalarmhi".}: uint32
    lactloadlo* {.importc: "lactloadlo".}: uint32
    lactloadhi* {.importc: "lactloadhi".}: uint32
    lactload* {.importc: "lactload".}: uint32
    int_ena* {.importc: "int_ena".}: INNER_C_STRUCT_timer_group_struct_105
    int_raw* {.importc: "int_raw".}: INNER_C_STRUCT_timer_group_struct_112
    int_st_timers* {.importc: "int_st_timers".}: INNER_C_STRUCT_timer_group_struct_119
    int_clr_timers* {.importc: "int_clr_timers".}: INNER_C_STRUCT_timer_group_struct_126
    reserved_a8* {.importc: "reserved_a8".}: uint32
    reserved_ac* {.importc: "reserved_ac".}: uint32
    reserved_b0* {.importc: "reserved_b0".}: uint32
    reserved_b4* {.importc: "reserved_b4".}: uint32
    reserved_b8* {.importc: "reserved_b8".}: uint32
    reserved_bc* {.importc: "reserved_bc".}: uint32
    reserved_c0* {.importc: "reserved_c0".}: uint32
    reserved_c4* {.importc: "reserved_c4".}: uint32
    reserved_c8* {.importc: "reserved_c8".}: uint32
    reserved_cc* {.importc: "reserved_cc".}: uint32
    reserved_d0* {.importc: "reserved_d0".}: uint32
    reserved_d4* {.importc: "reserved_d4".}: uint32
    reserved_d8* {.importc: "reserved_d8".}: uint32
    reserved_dc* {.importc: "reserved_dc".}: uint32
    reserved_e0* {.importc: "reserved_e0".}: uint32
    reserved_e4* {.importc: "reserved_e4".}: uint32
    reserved_e8* {.importc: "reserved_e8".}: uint32
    reserved_ec* {.importc: "reserved_ec".}: uint32
    reserved_f0* {.importc: "reserved_f0".}: uint32
    reserved_f4* {.importc: "reserved_f4".}: uint32
    timg_date* {.importc: "timg_date".}: INNER_C_STRUCT_timer_group_struct_153
    clk* {.importc: "clk".}: INNER_C_STRUCT_timer_group_struct_157


var TIMERG0* {.importc: "TIMERG0", header: tgs_header.}: timg_dev_t
var TIMERG1* {.importc: "TIMERG1", header: tgs_header.}: timg_dev_t

var TIMG_WDT_WKEY_VALUE* {.importc: "$1", header: tgs_header.}: uint32

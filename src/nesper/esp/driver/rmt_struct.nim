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

type
  INNER_C_STRUCT_rmt_struct_30* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    div_cnt* {.importc: "div_cnt",  bitsize: 8.}: uint32 ## This register is used to configure the  frequency divider's factor in channel0-7.
    idle_thres* {.importc: "idle_thres", bitsize: 16.}: uint32 ## In receive mode when no edge is detected on the input signal for longer than reg_idle_thres_ch0 then the receive process is done.
    mem_size* {.importc: "mem_size", bitsize: 4.}: uint32 ## This register is used to configure the the amount of memory blocks allocated to channel0-7.
    carrier_en* {.importc: "carrier_en", bitsize: 1.}: uint32 ## This is the carrier modulation enable control bit for channel0-7.
    carrier_out_lv* {.importc: "carrier_out_lv", bitsize: 1.}: uint32 ## This bit is used to configure the way carrier wave is modulated for  channel0-7.1'b1:transmit on low output level  1'b0:transmit  on high output level.
    mem_pd* {.importc: "mem_pd", bitsize: 1.}: uint32 ## This bit is used to reduce power consumed by memory. 1:memory is in low power state.
    clk_en* {.importc: "clk_en", bitsize: 1.}: uint32 ## This bit  is used  to control clock.when software configure RMT internal registers  it controls the register clock.

  INNER_C_UNION_rmt_struct_29* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_37* {.importc: "ano_rmt_struct_37".}: INNER_C_STRUCT_rmt_struct_30
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_42* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    tx_start* {.importc: "tx_start", bitsize: 1.}: uint32 ## Set this bit to start sending data for channel0-7.
    rx_en* {.importc: "rx_en", bitsize: 1.}: uint32 ## Set this bit to enable receiving data for channel0-7.
    mem_wr_rst* {.importc: "mem_wr_rst", bitsize: 1.}: uint32 ## Set this bit to reset write ram address for channel0-7 by receiver access.
    mem_rd_rst* {.importc: "mem_rd_rst", bitsize: 1.}: uint32 ## Set this bit to reset read ram address for channel0-7 by transmitter access.
    apb_mem_rst* {.importc: "apb_mem_rst", bitsize: 1.}: uint32 ## Set this bit to reset W/R ram address for channel0-7 by apb fifo access (using fifo is discouraged, please see the note above at data_ch[] item)
    mem_owner* {.importc: "mem_owner", bitsize: 1.}: uint32 ## This is the mark of channel0-7's ram usage right.1'b1：receiver uses the ram  0：transmitter uses the ram
    tx_conti_mode* {.importc: "tx_conti_mode", bitsize: 1.}: uint32 ## Set this bit to continue sending  from the first data to the last data in channel0-7 again and again.
    rx_filter_en* {.importc: "rx_filter_en", bitsize: 1.}: uint32 ## This is the receive filter enable bit for channel0-7.
    rx_filter_thres* {.importc: "rx_filter_thres", bitsize: 8.}: uint32 ## in receive mode  channel0-7 ignore input pulse when the pulse width is smaller then this value.
    ref_cnt_rst* {.importc: "ref_cnt_rst", bitsize: 1.}: uint32 ## This bit is used to reset divider in channel0-7.
    ref_always_on* {.importc: "ref_always_on", bitsize: 1.}: uint32 ## This bit is used to select base clock. 1'b1:clk_apb  1'b0:clk_ref
    idle_out_lv* {.importc: "idle_out_lv", bitsize: 1.}: uint32 ## This bit configures the output signal's level for channel0-7 in IDLE state.
    idle_out_en* {.importc: "idle_out_en", bitsize: 1.}: uint32 ## This is the output enable control bit for channel0-7 in IDLE state.
    reserved20* {.importc: "reserved20", bitsize: 12.}: uint32

  INNER_C_UNION_rmt_struct_41* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_56* {.importc: "ano_rmt_struct_56".}: INNER_C_STRUCT_rmt_struct_42
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_28* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    conf0* {.importc: "conf0".}: INNER_C_UNION_rmt_struct_29
    conf1* {.importc: "conf1".}: INNER_C_UNION_rmt_struct_41

  INNER_C_STRUCT_rmt_struct_64* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    ch0_tx_end* {.importc: "ch0_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 0 turns to high level when the transmit process is done.
    ch0_rx_end* {.importc: "ch0_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 0 turns to high level when the receive process is done.
    ch0_err* {.importc: "ch0_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 0 turns to high level when channel 0 detects some errors.
    ch1_tx_end* {.importc: "ch1_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 1 turns to high level when the transmit process is done.
    ch1_rx_end* {.importc: "ch1_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 1 turns to high level when the receive process is done.
    ch1_err* {.importc: "ch1_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 1 turns to high level when channel 1 detects some errors.
    ch2_tx_end* {.importc: "ch2_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 2 turns to high level when the transmit process is done.
    ch2_rx_end* {.importc: "ch2_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 2 turns to high level when the receive process is done.
    ch2_err* {.importc: "ch2_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 2 turns to high level when channel 2 detects some errors.
    ch3_tx_end* {.importc: "ch3_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 3 turns to high level when the transmit process is done.
    ch3_rx_end* {.importc: "ch3_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 3 turns to high level when the receive process is done.
    ch3_err* {.importc: "ch3_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 3 turns to high level when channel 3 detects some errors.
    ch4_tx_end* {.importc: "ch4_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 4 turns to high level when the transmit process is done.
    ch4_rx_end* {.importc: "ch4_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 4 turns to high level when the receive process is done.
    ch4_err* {.importc: "ch4_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 4 turns to high level when channel 4 detects some errors.
    ch5_tx_end* {.importc: "ch5_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 5 turns to high level when the transmit process is done.
    ch5_rx_end* {.importc: "ch5_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 5 turns to high level when the receive process is done.
    ch5_err* {.importc: "ch5_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 5 turns to high level when channel 5 detects some errors.
    ch6_tx_end* {.importc: "ch6_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 6 turns to high level when the transmit process is done.
    ch6_rx_end* {.importc: "ch6_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 6 turns to high level when the receive process is done.
    ch6_err* {.importc: "ch6_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 6 turns to high level when channel 6 detects some errors.
    ch7_tx_end* {.importc: "ch7_tx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 7 turns to high level when the transmit process is done.
    ch7_rx_end* {.importc: "ch7_rx_end", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 7 turns to high level when the receive process is done.
    ch7_err* {.importc: "ch7_err", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 7 turns to high level when channel 7 detects some errors.
    ch0_tx_thr_event* {.importc: "ch0_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 0 turns to high level when transmitter in channel0  have send data more than  reg_rmt_tx_lim_ch0  after detecting this interrupt  software can updata the old data with new data.
    ch1_tx_thr_event* {.importc: "ch1_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 1 turns to high level when transmitter in channel1  have send data more than  reg_rmt_tx_lim_ch1  after detecting this interrupt  software can updata the old data with new data.
    ch2_tx_thr_event* {.importc: "ch2_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 2 turns to high level when transmitter in channel2  have send data more than  reg_rmt_tx_lim_ch2  after detecting this interrupt  software can updata the old data with new data.
    ch3_tx_thr_event* {.importc: "ch3_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 3 turns to high level when transmitter in channel3  have send data more than  reg_rmt_tx_lim_ch3  after detecting this interrupt  software can updata the old data with new data.
    ch4_tx_thr_event* {.importc: "ch4_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 4 turns to high level when transmitter in channel4  have send data more than  reg_rmt_tx_lim_ch4  after detecting this interrupt  software can updata the old data with new data.
    ch5_tx_thr_event* {.importc: "ch5_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 5 turns to high level when transmitter in channel5  have send data more than  reg_rmt_tx_lim_ch5  after detecting this interrupt  software can updata the old data with new data.
    ch6_tx_thr_event* {.importc: "ch6_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 6 turns to high level when transmitter in channel6  have send data more than  reg_rmt_tx_lim_ch6  after detecting this interrupt  software can updata the old data with new data.
    ch7_tx_thr_event* {.importc: "ch7_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt raw bit for channel 7 turns to high level when transmitter in channel7  have send data more than  reg_rmt_tx_lim_ch7  after detecting this interrupt  software can updata the old data with new data.

  INNER_C_UNION_rmt_struct_63* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_96* {.importc: "ano_rmt_struct_96".}: INNER_C_STRUCT_rmt_struct_64
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_101* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    ch0_tx_end* {.importc: "ch0_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 0's mt_ch0_tx_end_int_raw when mt_ch0_tx_end_int_ena is set to 0.
    ch0_rx_end* {.importc: "ch0_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 0's rmt_ch0_rx_end_int_raw when  rmt_ch0_rx_end_int_ena is set to 0.
    ch0_err* {.importc: "ch0_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 0's rmt_ch0_err_int_raw when  rmt_ch0_err_int_ena is set to 0.
    ch1_tx_end* {.importc: "ch1_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 1's mt_ch1_tx_end_int_raw when mt_ch1_tx_end_int_ena is set to 1.
    ch1_rx_end* {.importc: "ch1_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 1's rmt_ch1_rx_end_int_raw when  rmt_ch1_rx_end_int_ena is set to 1.
    ch1_err* {.importc: "ch1_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 1's rmt_ch1_err_int_raw when  rmt_ch1_err_int_ena is set to 1.
    ch2_tx_end* {.importc: "ch2_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 2's mt_ch2_tx_end_int_raw when mt_ch2_tx_end_int_ena is set to 1.
    ch2_rx_end* {.importc: "ch2_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 2's rmt_ch2_rx_end_int_raw when  rmt_ch2_rx_end_int_ena is set to 1.
    ch2_err* {.importc: "ch2_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 2's rmt_ch2_err_int_raw when  rmt_ch2_err_int_ena is set to 1.
    ch3_tx_end* {.importc: "ch3_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 3's mt_ch3_tx_end_int_raw when mt_ch3_tx_end_int_ena is set to 1.
    ch3_rx_end* {.importc: "ch3_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 3's rmt_ch3_rx_end_int_raw when  rmt_ch3_rx_end_int_ena is set to 1.
    ch3_err* {.importc: "ch3_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 3's rmt_ch3_err_int_raw when  rmt_ch3_err_int_ena is set to 1.
    ch4_tx_end* {.importc: "ch4_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 4's mt_ch4_tx_end_int_raw when mt_ch4_tx_end_int_ena is set to 1.
    ch4_rx_end* {.importc: "ch4_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 4's rmt_ch4_rx_end_int_raw when  rmt_ch4_rx_end_int_ena is set to 1.
    ch4_err* {.importc: "ch4_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 4's rmt_ch4_err_int_raw when  rmt_ch4_err_int_ena is set to 1.
    ch5_tx_end* {.importc: "ch5_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 5's mt_ch5_tx_end_int_raw when mt_ch5_tx_end_int_ena is set to 1.
    ch5_rx_end* {.importc: "ch5_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 5's rmt_ch5_rx_end_int_raw when  rmt_ch5_rx_end_int_ena is set to 1.
    ch5_err* {.importc: "ch5_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 5's rmt_ch5_err_int_raw when  rmt_ch5_err_int_ena is set to 1.
    ch6_tx_end* {.importc: "ch6_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 6's mt_ch6_tx_end_int_raw when mt_ch6_tx_end_int_ena is set to 1.
    ch6_rx_end* {.importc: "ch6_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 6's rmt_ch6_rx_end_int_raw when  rmt_ch6_rx_end_int_ena is set to 1.
    ch6_err* {.importc: "ch6_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 6's rmt_ch6_err_int_raw when  rmt_ch6_err_int_ena is set to 1.
    ch7_tx_end* {.importc: "ch7_tx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 7's mt_ch7_tx_end_int_raw when mt_ch7_tx_end_int_ena is set to 1.
    ch7_rx_end* {.importc: "ch7_rx_end", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 7's rmt_ch7_rx_end_int_raw when  rmt_ch7_rx_end_int_ena is set to 1.
    ch7_err* {.importc: "ch7_err", bitsize: 1.}: uint32 ## The interrupt  state bit for channel 7's rmt_ch7_err_int_raw when  rmt_ch7_err_int_ena is set to 1.
    ch0_tx_thr_event* {.importc: "ch0_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 0's rmt_ch0_tx_thr_event_int_raw when mt_ch0_tx_thr_event_int_ena is set to 1.
    ch1_tx_thr_event* {.importc: "ch1_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 1's rmt_ch1_tx_thr_event_int_raw when mt_ch1_tx_thr_event_int_ena is set to 1.
    ch2_tx_thr_event* {.importc: "ch2_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 2's rmt_ch2_tx_thr_event_int_raw when mt_ch2_tx_thr_event_int_ena is set to 1.
    ch3_tx_thr_event* {.importc: "ch3_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 3's rmt_ch3_tx_thr_event_int_raw when mt_ch3_tx_thr_event_int_ena is set to 1.
    ch4_tx_thr_event* {.importc: "ch4_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 4's rmt_ch4_tx_thr_event_int_raw when mt_ch4_tx_thr_event_int_ena is set to 1.
    ch5_tx_thr_event* {.importc: "ch5_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 5's rmt_ch5_tx_thr_event_int_raw when mt_ch5_tx_thr_event_int_ena is set to 1.
    ch6_tx_thr_event* {.importc: "ch6_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 6's rmt_ch6_tx_thr_event_int_raw when mt_ch6_tx_thr_event_int_ena is set to 1.
    ch7_tx_thr_event* {.importc: "ch7_tx_thr_event", bitsize: 1.}: uint32 ## The interrupt state bit  for channel 7's rmt_ch7_tx_thr_event_int_raw when mt_ch7_tx_thr_event_int_ena is set to 1.

  INNER_C_UNION_rmt_struct_100* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_133* {.importc: "ano_rmt_struct_133".}: INNER_C_STRUCT_rmt_struct_101
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_138* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    ch0_tx_end* {.importc: "ch0_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch0_tx_end_int_st.
    ch0_rx_end* {.importc: "ch0_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch0_rx_end_int_st.
    ch0_err* {.importc: "ch0_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch0_err_int_st.
    ch1_tx_end* {.importc: "ch1_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch1_tx_end_int_st.
    ch1_rx_end* {.importc: "ch1_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch1_rx_end_int_st.
    ch1_err* {.importc: "ch1_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch1_err_int_st.
    ch2_tx_end* {.importc: "ch2_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch2_tx_end_int_st.
    ch2_rx_end* {.importc: "ch2_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch2_rx_end_int_st.
    ch2_err* {.importc: "ch2_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch2_err_int_st.
    ch3_tx_end* {.importc: "ch3_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch3_tx_end_int_st.
    ch3_rx_end* {.importc: "ch3_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch3_rx_end_int_st.
    ch3_err* {.importc: "ch3_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch3_err_int_st.
    ch4_tx_end* {.importc: "ch4_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch4_tx_end_int_st.
    ch4_rx_end* {.importc: "ch4_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch4_rx_end_int_st.
    ch4_err* {.importc: "ch4_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch4_err_int_st.
    ch5_tx_end* {.importc: "ch5_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch5_tx_end_int_st.
    ch5_rx_end* {.importc: "ch5_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch5_rx_end_int_st.
    ch5_err* {.importc: "ch5_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch5_err_int_st.
    ch6_tx_end* {.importc: "ch6_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch6_tx_end_int_st.
    ch6_rx_end* {.importc: "ch6_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch6_rx_end_int_st.
    ch6_err* {.importc: "ch6_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch6_err_int_st.
    ch7_tx_end* {.importc: "ch7_tx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch7_tx_end_int_st.
    ch7_rx_end* {.importc: "ch7_rx_end", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch7_rx_end_int_st.
    ch7_err* {.importc: "ch7_err", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch7_err_int_st.
    ch0_tx_thr_event* {.importc: "ch0_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch0_tx_thr_event_int_st.
    ch1_tx_thr_event* {.importc: "ch1_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch1_tx_thr_event_int_st.
    ch2_tx_thr_event* {.importc: "ch2_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch2_tx_thr_event_int_st.
    ch3_tx_thr_event* {.importc: "ch3_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch3_tx_thr_event_int_st.
    ch4_tx_thr_event* {.importc: "ch4_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch4_tx_thr_event_int_st.
    ch5_tx_thr_event* {.importc: "ch5_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch5_tx_thr_event_int_st.
    ch6_tx_thr_event* {.importc: "ch6_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch6_tx_thr_event_int_st.
    ch7_tx_thr_event* {.importc: "ch7_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to enable rmt_ch7_tx_thr_event_int_st.

  INNER_C_UNION_rmt_struct_137* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_170* {.importc: "ano_rmt_struct_170".}: INNER_C_STRUCT_rmt_struct_138
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_175* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    ch0_tx_end* {.importc: "ch0_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch0_rx_end_int_raw..
    ch0_rx_end* {.importc: "ch0_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch0_tx_end_int_raw.
    ch0_err* {.importc: "ch0_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch0_err_int_raw.
    ch1_tx_end* {.importc: "ch1_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch1_rx_end_int_raw..
    ch1_rx_end* {.importc: "ch1_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch1_tx_end_int_raw.
    ch1_err* {.importc: "ch1_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch1_err_int_raw.
    ch2_tx_end* {.importc: "ch2_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch2_rx_end_int_raw..
    ch2_rx_end* {.importc: "ch2_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch2_tx_end_int_raw.
    ch2_err* {.importc: "ch2_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch2_err_int_raw.
    ch3_tx_end* {.importc: "ch3_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch3_rx_end_int_raw..
    ch3_rx_end* {.importc: "ch3_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch3_tx_end_int_raw.
    ch3_err* {.importc: "ch3_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch3_err_int_raw.
    ch4_tx_end* {.importc: "ch4_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch4_rx_end_int_raw..
    ch4_rx_end* {.importc: "ch4_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch4_tx_end_int_raw.
    ch4_err* {.importc: "ch4_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch4_err_int_raw.
    ch5_tx_end* {.importc: "ch5_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch5_rx_end_int_raw..
    ch5_rx_end* {.importc: "ch5_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch5_tx_end_int_raw.
    ch5_err* {.importc: "ch5_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch5_err_int_raw.
    ch6_tx_end* {.importc: "ch6_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch6_rx_end_int_raw..
    ch6_rx_end* {.importc: "ch6_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch6_tx_end_int_raw.
    ch6_err* {.importc: "ch6_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch6_err_int_raw.
    ch7_tx_end* {.importc: "ch7_tx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch7_rx_end_int_raw..
    ch7_rx_end* {.importc: "ch7_rx_end", bitsize: 1.}: uint32 ## Set this bit to clear the rmt_ch7_tx_end_int_raw.
    ch7_err* {.importc: "ch7_err", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch7_err_int_raw.
    ch0_tx_thr_event* {.importc: "ch0_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch0_tx_thr_event_int_raw interrupt.
    ch1_tx_thr_event* {.importc: "ch1_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch1_tx_thr_event_int_raw interrupt.
    ch2_tx_thr_event* {.importc: "ch2_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch2_tx_thr_event_int_raw interrupt.
    ch3_tx_thr_event* {.importc: "ch3_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch3_tx_thr_event_int_raw interrupt.
    ch4_tx_thr_event* {.importc: "ch4_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch4_tx_thr_event_int_raw interrupt.
    ch5_tx_thr_event* {.importc: "ch5_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch5_tx_thr_event_int_raw interrupt.
    ch6_tx_thr_event* {.importc: "ch6_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch6_tx_thr_event_int_raw interrupt.
    ch7_tx_thr_event* {.importc: "ch7_tx_thr_event", bitsize: 1.}: uint32 ## Set this bit to clear the  rmt_ch7_tx_thr_event_int_raw interrupt.

  INNER_C_UNION_rmt_struct_174* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_207* {.importc: "ano_rmt_struct_207".}: INNER_C_STRUCT_rmt_struct_175
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_212* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    low* {.importc: "low", bitsize: 16.}: uint32 ## This register is used to configure carrier wave's low level value for channel0-7.
    high* {.importc: "high", bitsize: 16.}: uint32 ## This register is used to configure carrier wave's high level value for channel0-7.

  INNER_C_UNION_rmt_struct_211* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_214* {.importc: "ano_rmt_struct_214".}: INNER_C_STRUCT_rmt_struct_212
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_219* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    limit* {.importc: "limit", bitsize: 9.}: uint32 ## When channel0-7 sends more than reg_rmt_tx_lim_ch0 data then channel0-7 produce the relative interrupt.
    reserved9* {.importc: "reserved9", bitsize: 23.}: uint32

  INNER_C_UNION_rmt_struct_218* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_221* {.importc: "ano_rmt_struct_221".}: INNER_C_STRUCT_rmt_struct_219
    val* {.importc: "val".}: uint32

  INNER_C_STRUCT_rmt_struct_226* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    fifo_mask* {.importc: "fifo_mask", bitsize: 1.}: uint32 ## Set this bit to enable RMTMEM and disable apb fifo access (using fifo is discouraged, please see the note above at data_ch[] item)
    mem_tx_wrap_en* {.importc: "mem_tx_wrap_en", bitsize: 1.}: uint32 ## when data need to be send is more than channel's mem can store  then set this bit to enable reuse of mem this bit is used together with reg_rmt_tx_lim_chn.
    reserved2* {.importc: "reserved2", bitsize: 30.}: uint32

  INNER_C_UNION_rmt_struct_225* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_229* {.importc: "ano_rmt_struct_229".}: INNER_C_STRUCT_rmt_struct_226
    val* {.importc: "val".}: uint32

  rmt_dev_t* {.importc: "rmt_dev_t", header: "rmt_struct.h", bycopy.} = object
    data_ch* {.importc: "data_ch".}: array[8, uint32] ## The R/W ram address for channel0-7 by apb fifo access.
                                                   ##                                                         Note that in some circumstances, data read from the FIFO may get lost. As RMT memory area accesses using the RMTMEM method do not have this issue
                                                   ##                                                         and provide all the functionality that the FIFO register has, it is encouraged to use that instead.
    conf_ch* {.importc: "conf_ch".}: array[8, INNER_C_STRUCT_rmt_struct_28]
    status_ch* {.importc: "status_ch".}: array[8, uint32] ## The status for channel0-7
    apb_mem_addr_ch* {.importc: "apb_mem_addr_ch".}: array[8, uint32] ## The ram relative address in channel0-7 by apb fifo access (using fifo is discouraged, please see the note above at data_ch[] item)
    int_raw* {.importc: "int_raw".}: INNER_C_UNION_rmt_struct_63
    int_st* {.importc: "int_st".}: INNER_C_UNION_rmt_struct_100
    int_ena* {.importc: "int_ena".}: INNER_C_UNION_rmt_struct_137
    int_clr* {.importc: "int_clr".}: INNER_C_UNION_rmt_struct_174
    carrier_duty_ch* {.importc: "carrier_duty_ch".}: array[8,
        INNER_C_UNION_rmt_struct_211]
    tx_lim_ch* {.importc: "tx_lim_ch".}: array[8, INNER_C_UNION_rmt_struct_218]
    apb_conf* {.importc: "apb_conf".}: INNER_C_UNION_rmt_struct_225
    reserved_f4* {.importc: "reserved_f4".}: uint32
    reserved_f8* {.importc: "reserved_f8".}: uint32
    date* {.importc: "date".}: uint32 ## This is the version register.


var RMT* {.importc: "RMT", header: "rmt_struct.h".}: rmt_dev_t

type
  INNER_C_STRUCT_rmt_struct_241* {.importc: "no_name", header: "rmt_struct.h", bycopy.} = object
    duration0* {.importc: "duration0", bitsize: 15.}: uint32
    level0* {.importc: "level0", bitsize: 1.}: uint32
    duration1* {.importc: "duration1", bitsize: 15.}: uint32
    level1* {.importc: "level1", bitsize: 1.}: uint32

  INNER_C_UNION_rmt_struct_240* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_245* {.importc: "ano_rmt_struct_245".}: INNER_C_STRUCT_rmt_struct_241
    val* {.importc: "val".}: uint32

  rmt_item32_t* {.importc: "rmt_item32_t", header: "rmt_struct.h", bycopy.} = object
    ano_rmt_struct_247* {.importc: "ano_rmt_struct_247".}: INNER_C_UNION_rmt_struct_240


## Allow access to RMT memory using RMTMEM.chan[0].data32[8]

type
  # TODO: This doesn't look right
  INNER_C_UNION_rmt_struct_254* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    data32* {.importc: "data32".}: array[64, rmt_item32_t]

  INNER_C_STRUCT_rmt_struct_253* {.importc: "no_name", header: "rmt_struct.h", bycopy, union.} = object
    ano_rmt_struct_255* {.importc: "ano_rmt_struct_255".}: INNER_C_UNION_rmt_struct_254

  rmt_mem_t* {.importc: "rmt_mem_t", header: "rmt_struct.h", bycopy.} = object
    chan* {.importc: "chan".}: array[8, INNER_C_STRUCT_rmt_struct_253]


var RMTMEM* {.importc: "RMTMEM", header: "rmt_struct.h".}: rmt_mem_t

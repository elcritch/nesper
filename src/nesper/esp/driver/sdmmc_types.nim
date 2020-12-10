##
##  Copyright (c) 2006 Uwe Stuehler <uwe@openbsd.org>
##  Adaptations to ESP-IDF Copyright (c) 2016 Espressif Systems (Shanghai) PTE LTD
##
##  Permission to use, copy, modify, and distribute this software for any
##  purpose with or without fee is hereby granted, provided that the above
##  copyright notice and this permission notice appear in all copies.
##
##  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
##  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
##  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
##  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
##  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
##  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
##  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##

import ../../consts

const theader = """sdmcc_types.h"""

type

  ## Decoded values from SD card Card Specific Data register

  sdmmc_csd_t* {.importc: "sdmmc_csd_t", header: theader, bycopy.} = object
    csd_ver* : int # CSD structure format
    mmc_ver* : int # MMC version (for CID format)
    capacity* : int  # total number of sectors
    sector_size* : int # sector size in bytes
    read_block_len* : int  # block length for reads
    card_command_class* : int  # Card Command Class for SD
    tr_speed* : int  # Max transfer speed

  ## Decoded values from SD card Card IDentification register

  sdmmc_cid_t* {.importc: "sdmmc_cid_t", header: theader, bycopy.} = object
    mfg_id* : int  # manufacturer identification number
    oem_id* : int  # OEM/product identification number
    name* : array[8, char] # product name (MMC v1 has the longest)
    revision* : int  # product revision
    serial* : int  # product serial number
    date* : int  # manufacturing date

  ## Decoded values from SD Configuration Register
 
  sdmmc_scr_t* {.importc: "sdmmc_scr_t", header: theader, bycopy.} = object
    sd_spec* : int # SD Physical layer specification version, reported by card 
    bus_width* : int # bus widths supported by card: BIT(0) — 1-bit bus, BIT(2) — 4-bit bus
 
  ## Decoded values of Extended Card Specific Data

  sdmmc_ext_csd_t* {.importc: "sdmmc_ext_csd_t", header: theader, bycopy.} = object
    power_class*: uint8  # Power class used by the card

  ## SD/MMC command response buffer

  sdmmc_response_t* {.importc: "sdmmc_response_t", header: theader, bycopy.} =  array[4, uint32]

  ## SD SWITCH_FUNC response buffer

  sdmmc_switch_func_rsp_t* {.importc: "sdmmc_switch_func_rsp_t", header: theader, bycopy.} = object
    data* : array[512 div 8 div sizeof(uint32), uint32]  # response data

  ## SD/MMC command information
  
  sdmmc_command_t* {.importc: "sdmmc_command_t", header: theader, bycopy.} = object
    opcode* : uint32 # SD or MMC command index
    arg* : uint32  # SD/MMC command argument
    response* : sdmmc_response_t # response buffer
    data* : pointer  # buffer to send or read into
    datalen* : uint32  # length of data buffer
    blklen* : uint32 # block length
    flags* : int # see below
    error* : esp_err_t # error returned from transfer
    timeout_ms* : int  # response timeout, in milliseconds

template SCF_CMD*(flags): untyped = ((flags) & 0x00f0)
  
const
  ## @cond 
  SCF_ITSDONE*     = 0x0001 # command is complete
  # SCF_CMD(flags)  = ((flags) & 0x00f0)
  SCF_CMD_AC*      = 0x0000
  SCF_CMD_ADTC*    = 0x0010
  SCF_CMD_BC*      = 0x0020
  SCF_CMD_BCR*     = 0x0030
  SCF_CMD_READ*    = 0x0040 #read command (data expected)
  SCF_RSP_BSY*     = 0x0100
  SCF_RSP_136*     = 0x0200
  SCF_RSP_CRC*     = 0x0400
  SCF_RSP_IDX*     = 0x0800
  SCF_RSP_PRESENT* = 0x1000
  ## response types
  SCF_RSP_R0*  = 0 # none
  SCF_RSP_R1*  = (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX)
  SCF_RSP_R1B* = (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX or SCF_RSP_BSY)
  SCF_RSP_R2*  = (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_136)
  SCF_RSP_R3*  = (SCF_RSP_PRESENT)
  SCF_RSP_R4*  = (SCF_RSP_PRESENT)
  SCF_RSP_R5*  = (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX)
  SCF_RSP_R5B* = (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX or SCF_RSP_BSY)
  SCF_RSP_R6*  = (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX)
  SCF_RSP_R7*  = (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX)
  ## special flags 
  SCF_WAIT_BUSY* = 0x2000  # Wait for completion of card busy signal before returning
  ## @endcond

type

  ##
  ## SD/MMC Host description
  ##
  ## @brief This structure defines properties of SD/MMC host and functions
  ##        of SD/MMC host which can be used by upper layers.
  ## 

  sdmmc_host_t* {.importc: "sdmmc_host_t", header: theader, bycopy.} = object
    flags* : uint32  # flags defining host properties
    
    slot* : int  # slot number, to be passed to host functions
    
    max_freq_khz* : int  # max frequency supported by the host
    io_voltage* : float  # I/O voltage used by the controller (voltage switching is not supported)
    
    init* : proc() : esp_err_t {.cdecl.} # Host function to initialize the driver
    
    set_bus_width* : proc(slot : int, width : uint32) : esp_err_t {.cdecl.} # Host function to set bus width
    get_bus_width* : proc(slot : int) : uint32 {.cdecl.}  # host function to get bus width

    set_bus_ddr_mode* : proc(slot : int , ddr_enable : bool) : esp_err_t {.cdecl.} # host function to set DDR mode
    set_card_clk*     : proc(slot : int, freq_khz : uint32) : esp_err_t {.cdecl.} # Host function to set card clock frequency 
    do_transaction*   : proc(slot : int, cmdinfo : ptr sdmmc_command_t) : esp_err_t {.cdecl.} # Host function to do a transaction
    deinit*           : proc() : esp_err_t {.cdecl.} # Host function to deinitialize the driver
    io_int_enable*    : proc(slot : int) : esp_err_t {.cdecl.} # Host function to enable SDIO interrupt line
    io_int_wait*      : proc(slot : int, timeout_ticks : TickType_t) : esp_err_t {.cdecl.} # Host function to wait for SDIO interrupt line to be active
    
    command_timeout_ms* : int  # Timeout, in milliseconds, of a single command. Set to 0 to use the default value.
    
## Host flags

const
  SDMMC_HOST_FLAG_1BIT* = BIT(0)  # host supports 1-line SD and MMC protocol
  SDMMC_HOST_FLAG_4BIT* = BIT(1)  # host supports 4-line SD and MMC protocol
  SDMMC_HOST_FLAG_8BIT* = BIT(2)  # host supports 8-line MMC protocol 
  SDMMC_HOST_FLAG_SPI* = BIT(3) # host supports SPI protocol
  SDMMC_HOST_FLAG_DDR* = BIT(4) # host supports DDR mode for SD/MMC

## SD/MMC speeds

const
  SDMMC_FREQ_DEFAULT* = 20000 # SD/MMC Default speed (limited by clock divider)
  SDMMC_FREQ_HIGHSPEED* = 40000 # SD High speed (limited by clock divider)
  SDMMC_FREQ_PROBING* = 400 # SD/MMC probing speed
  SDMMC_FREQ_52M* = 52000 # MMC 52MHz speed 
  SDMMC_FREQ_26M* = 26000 # MMC 26MHz speed

type
  cid_union_type* {.union.} = object
    cid* : sdmmc_cid_t           # decoded CID (Card IDentification) register value 
    raw_cid* : sdmmc_response_t  # raw CID of MMC card to be decoded after the CSD is fetched in the data transfer mode

  ## SD/MMC card information structure

  sdmmc_card_t* {.importc: "sdmmc_card_t", header: theader, bycopy.} = object
    host* : sdmmc_host_t # Host with which the card is associated
    
    ocr* : uint32  # OCR (Operation Conditions Register) value
    
    cid_union* : cid_union_type
    
    csd* : sdmmc_csd_t # decoded CSD (Card-Specific Data) register value
    scr* : sdmmc_scr_t # decoded SCR (SD card Configuration Register) value
    ext_csd* : sdmmc_ext_csd_t # decoded EXT_CSD (Extended Card Specific Data) register value
    
    rca* : uint16  # RCA (Relative Card Address)
    max_freq_khz* : uint16 # Maximum frequency, in kHz, supported by the card
    
    is_mem* {.bitsize: 1.} : uint32 # Bit indicates if the card is a memory card
    is_sdio* {.bitsize: 1.} : uint32 # Bit indicates if the card is an IO card
    is_mmc* {.bitsize: 1.} : uint32  # Bit indicates if the card is MMC
    num_io_functions* {.bitsize: 3.} : uint32 # If is_sdio is 1, contains the number of IO functions on the card
    log_bus_width* {.bitsize: 2.} : uint32 # log2(bus width supported by card)
    is_ddr* {.bitsize: 1.} : uint32  # Card supports DDR mode
    reserved* {.bitsize: 23.} : uint32 # Reserved for future expansion
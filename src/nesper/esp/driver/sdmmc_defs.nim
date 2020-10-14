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

##  MMC commands
##  response type

const
  MMC_GO_IDLE_STATE* = 0
  MMC_SEND_OP_COND* = 1
  MMC_ALL_SEND_CID* = 2
  MMC_SET_RELATIVE_ADDR* = 3
  MMC_SWITCH* = 6
  MMC_SELECT_CARD* = 7
  MMC_SEND_EXT_CSD* = 8
  MMC_SEND_CSD* = 9
  MMC_SEND_CID* = 10
  MMC_READ_DAT_UNTIL_STOP* = 11
  MMC_STOP_TRANSMISSION* = 12
  MMC_SEND_STATUS* = 13
  MMC_SET_BLOCKLEN* = 16
  MMC_READ_BLOCK_SINGLE* = 17
  MMC_READ_BLOCK_MULTIPLE* = 18
  MMC_WRITE_DAT_UNTIL_STOP* = 20
  MMC_SET_BLOCK_COUNT* = 23
  MMC_WRITE_BLOCK_SINGLE* = 24
  MMC_WRITE_BLOCK_MULTIPLE* = 25
  MMC_APP_CMD* = 55

##  SD commands
##  response type

const
  SD_SEND_RELATIVE_ADDR* = 3
  SD_SEND_SWITCH_FUNC* = 6
  SD_SEND_IF_COND* = 8
  SD_READ_OCR* = 58
  SD_CRC_ON_OFF* = 59

##  SD application commands
##  response type

const
  SD_APP_SET_BUS_WIDTH* = 6
  SD_APP_SD_STATUS* = 13
  SD_APP_OP_COND* = 41
  SD_APP_SEND_SCR* = 51

##  SD IO commands

const
  SD_IO_SEND_OP_COND* = 5
  SD_IO_RW_DIRECT* = 52
  SD_IO_RW_EXTENDED* = 53

##  OCR bits

const
  MMC_OCR_MEM_READY* = (1 shl 31) ##  memory power-up status bit
  MMC_OCR_ACCESS_MODE_MASK* = 0x60000000
  MMC_OCR_SECTOR_MODE* = (1 shl 30)
  MMC_OCR_BYTE_MODE* = (1 shl 29)
  MMC_OCR_3_5V_3_6V* = (1 shl 23)
  MMC_OCR_3_4V_3_5V* = (1 shl 22)
  MMC_OCR_3_3V_3_4V* = (1 shl 21)
  MMC_OCR_3_2V_3_3V* = (1 shl 20)
  MMC_OCR_3_1V_3_2V* = (1 shl 19)
  MMC_OCR_3_0V_3_1V* = (1 shl 18)
  MMC_OCR_2_9V_3_0V* = (1 shl 17)
  MMC_OCR_2_8V_2_9V* = (1 shl 16)
  MMC_OCR_2_7V_2_8V* = (1 shl 15)
  MMC_OCR_2_6V_2_7V* = (1 shl 14)
  MMC_OCR_2_5V_2_6V* = (1 shl 13)
  MMC_OCR_2_4V_2_5V* = (1 shl 12)
  MMC_OCR_2_3V_2_4V* = (1 shl 11)
  MMC_OCR_2_2V_2_3V* = (1 shl 10)
  MMC_OCR_2_1V_2_2V* = (1 shl 9)
  MMC_OCR_2_0V_2_1V* = (1 shl 8)
  MMC_OCR_1_65V_1_95V* = (1 shl 7)
  SD_OCR_SDHC_CAP* = (1 shl 30)
  SD_OCR_VOL_MASK* = 0x00FF8000

##  SD mode R1 response type bits

const
  MMC_R1_READY_FOR_DATA* = (1 shl 8) ##  ready for next transfer
  MMC_R1_APP_CMD* = (1 shl 5)     ##  app. commands supported
  MMC_R1_SWITCH_ERROR* = (1 shl 7) ##  switch command did not succeed

##  SPI mode R1 response type bits

const
  SD_SPI_R1_IDLE_STATE* = (1 shl 0)
  SD_SPI_R1_ERASE_RST* = (1 shl 1)
  SD_SPI_R1_ILLEGAL_CMD* = (1 shl 2)
  SD_SPI_R1_CMD_CRC_ERR* = (1 shl 3)
  SD_SPI_R1_ERASE_SEQ_ERR* = (1 shl 4)
  SD_SPI_R1_ADDR_ERR* = (1 shl 5)
  SD_SPI_R1_PARAM_ERR* = (1 shl 6)
  SD_SPI_R1_NO_RESPONSE* = (1 shl 7)
  SDIO_R1_FUNC_NUM_ERR* = (1 shl 4)

##  48-bit response decoding (32 bits w/o CRC)

template MMC_R1*(resp: untyped): untyped =
  ((resp)[0])

template MMC_R3*(resp: untyped): untyped =
  ((resp)[0])

template MMC_R4*(resp: untyped): untyped =
  ((resp)[0])

template MMC_R5*(resp: untyped): untyped =
  ((resp)[0])

template SD_R6*(resp: untyped): untyped =
  ((resp)[0])

template MMC_R1_CURRENT_STATE*(resp: untyped): untyped =
  (((resp)[0] shr 9) and 0x0000000F)

##  SPI mode response decoding

template SD_SPI_R1*(resp: untyped): untyped =
  ((resp)[0] and 0x000000FF)

template SD_SPI_R2*(resp: untyped): untyped =
  ((resp)[0] and 0x0000FFFF)

template SD_SPI_R3*(resp: untyped): untyped =
  ((resp)[0])

template SD_SPI_R7*(resp: untyped): untyped =
  ((resp)[0])

##  SPI mode data response decoding

template SD_SPI_DATA_RSP_VALID*(resp_byte: untyped): untyped =
  (((resp_byte) and 0x00000011) == 0x00000001)

template SD_SPI_DATA_RSP*(resp_byte: untyped): untyped =
  (((resp_byte) shr 1) and 0x00000007)

const
  SD_SPI_DATA_ACCEPTED* = 0x00000002
  SD_SPI_DATA_CRC_ERROR* = 0x00000005
  SD_SPI_DATA_WR_ERROR* = 0x00000006

##  RCA argument and response

template MMC_ARG_RCA*(rca: untyped): untyped =
  ((rca) shl 16)

template SD_R6_RCA*(resp: untyped): untyped =
  (SD_R6((resp)) shr 16)

##  bus width argument

const
  SD_ARG_BUS_WIDTH_1* = 0
  SD_ARG_BUS_WIDTH_4* = 2

##  EXT_CSD fields

const
  EXT_CSD_BUS_WIDTH* = 183
  EXT_CSD_HS_TIMING* = 185
  EXT_CSD_REV* = 192
  EXT_CSD_STRUCTURE* = 194
  EXT_CSD_CARD_TYPE* = 196
  EXT_CSD_SEC_COUNT* = 212
  EXT_CSD_PWR_CL_26_360* = 203
  EXT_CSD_PWR_CL_52_360* = 202
  EXT_CSD_PWR_CL_26_195* = 201
  EXT_CSD_PWR_CL_52_195* = 200
  EXT_CSD_POWER_CLASS* = 187
  EXT_CSD_CMD_SET* = 191
  EXT_CSD_S_CMD_SET* = 504

##  EXT_CSD field definitions

const
  EXT_CSD_CMD_SET_NORMAL* = (1 shl 0)
  EXT_CSD_CMD_SET_SECURE* = (1 shl 1)
  EXT_CSD_CMD_SET_CPSECURE* = (1 shl 2)

##  EXT_CSD_HS_TIMING

const
  EXT_CSD_HS_TIMING_BC* = 0
  EXT_CSD_HS_TIMING_HS* = 1
  EXT_CSD_HS_TIMING_HS200* = 2
  EXT_CSD_HS_TIMING_HS400* = 3

##  EXT_CSD_BUS_WIDTH

const
  EXT_CSD_BUS_WIDTH_1* = 0
  EXT_CSD_BUS_WIDTH_4* = 1
  EXT_CSD_BUS_WIDTH_8* = 2
  EXT_CSD_BUS_WIDTH_4_DDR* = 5
  EXT_CSD_BUS_WIDTH_8_DDR* = 6

##  EXT_CSD_CARD_TYPE
##  The only currently valid values for this field are 0x01, 0x03, 0x07,
##  0x0B and 0x0F.

const
  EXT_CSD_CARD_TYPE_F_26M* = (1 shl 0) ##  SDR at "rated voltages
  EXT_CSD_CARD_TYPE_F_52M* = (1 shl 1) ##  SDR at "rated voltages
  EXT_CSD_CARD_TYPE_F_52M_1_8V* = (1 shl 2) ##  DDR, 1.8V or 3.3V I/O
  EXT_CSD_CARD_TYPE_F_52M_1_2V* = (1 shl 3) ##  DDR, 1.2V I/O
  EXT_CSD_CARD_TYPE_26M* = 0x00000001
  EXT_CSD_CARD_TYPE_52M* = 0x00000003
  EXT_CSD_CARD_TYPE_52M_V18* = 0x00000007
  EXT_CSD_CARD_TYPE_52M_V12* = 0x0000000B
  EXT_CSD_CARD_TYPE_52M_V12_18* = 0x0000000F

##  EXT_CSD MMC

const
  EXT_CSD_MMC_SIZE* = 512

##  MMC_SWITCH access mode

const
  MMC_SWITCH_MODE_CMD_SET* = 0x00000000
  MMC_SWITCH_MODE_SET_BITS* = 0x00000001
  MMC_SWITCH_MODE_CLEAR_BITS* = 0x00000002
  MMC_SWITCH_MODE_WRITE_BYTE* = 0x00000003

##  MMC R2 response (CSD)

template MMC_CSD_CSDVER*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 126, 2)

const
  MMC_CSD_CSDVER_1_0* = 1
  MMC_CSD_CSDVER_2_0* = 2
  MMC_CSD_CSDVER_EXT_CSD* = 3

template MMC_CSD_MMCVER*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 122, 4)

const
  MMC_CSD_MMCVER_1_0* = 0
  MMC_CSD_MMCVER_1_4* = 1
  MMC_CSD_MMCVER_2_0* = 2
  MMC_CSD_MMCVER_3_1* = 3
  MMC_CSD_MMCVER_4_0* = 4

template MMC_CSD_READ_BL_LEN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 80, 4)

template MMC_CSD_C_SIZE*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 62, 12)

template MMC_CSD_CAPACITY*(resp: untyped): untyped =
  ((MMC_CSD_C_SIZE((resp)) + 1) shl (MMC_CSD_C_SIZE_MULT((resp)) + 2))

template MMC_CSD_C_SIZE_MULT*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 47, 3)

##  MMC v1 R2 response (CID)

template MMC_CID_MID_V1*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 104, 24)

template MMC_CID_PNM_V1_CPY*(resp, pnm: untyped): void =
  while true:
    (pnm)[0] = MMC_RSP_BITS((resp), 96, 8)
    (pnm)[1] = MMC_RSP_BITS((resp), 88, 8)
    (pnm)[2] = MMC_RSP_BITS((resp), 80, 8)
    (pnm)[3] = MMC_RSP_BITS((resp), 72, 8)
    (pnm)[4] = MMC_RSP_BITS((resp), 64, 8)
    (pnm)[5] = MMC_RSP_BITS((resp), 56, 8)
    (pnm)[6] = MMC_RSP_BITS((resp), 48, 8)
    (pnm)[7] = '\x00'
    if not 0:
      break

template MMC_CID_REV_V1*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 40, 8)

template MMC_CID_PSN_V1*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 16, 24)

template MMC_CID_MDT_V1*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 8, 8)

##  MMC v2 R2 response (CID)

template MMC_CID_MID_V2*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 120, 8)

template MMC_CID_OID_V2*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 104, 16)

template MMC_CID_PNM_V2_CPY*(resp, pnm: untyped): void =
  while true:
    (pnm)[0] = MMC_RSP_BITS((resp), 96, 8)
    (pnm)[1] = MMC_RSP_BITS((resp), 88, 8)
    (pnm)[2] = MMC_RSP_BITS((resp), 80, 8)
    (pnm)[3] = MMC_RSP_BITS((resp), 72, 8)
    (pnm)[4] = MMC_RSP_BITS((resp), 64, 8)
    (pnm)[5] = MMC_RSP_BITS((resp), 56, 8)
    (pnm)[6] = '\x00'
    if not 0:
      break

template MMC_CID_PSN_V2*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 16, 32)

##  SD R2 response (CSD)

template SD_CSD_CSDVER*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 126, 2)

const
  SD_CSD_CSDVER_1_0* = 0
  SD_CSD_CSDVER_2_0* = 1

template SD_CSD_TAAC*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 112, 8)

const
  SD_CSD_TAAC_1_5_MSEC* = 0x00000026

template SD_CSD_NSAC*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 104, 8)

template SD_CSD_SPEED*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 96, 8)

const
  SD_CSD_SPEED_25_MHZ* = 0x00000032
  SD_CSD_SPEED_50_MHZ* = 0x0000005A

template SD_CSD_CCC*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 84, 12)

const
  SD_CSD_CCC_BASIC* = (1 shl 0)   ##  basic
  SD_CSD_CCC_BR* = (1 shl 2)      ##  block read
  SD_CSD_CCC_BW* = (1 shl 4)      ##  block write
  SD_CSD_CCC_ERASE* = (1 shl 5)   ##  erase
  SD_CSD_CCC_WP* = (1 shl 6)      ##  write protection
  SD_CSD_CCC_LC* = (1 shl 7)      ##  lock card
  SD_CSD_CCC_AS* = (1 shl 8)      ## application specific
  SD_CSD_CCC_IOM* = (1 shl 9)     ##  I/O mode
  SD_CSD_CCC_SWITCH* = (1 shl 10) ##  switch

template SD_CSD_READ_BL_LEN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 80, 4)

template SD_CSD_READ_BL_PARTIAL*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 79, 1)

template SD_CSD_WRITE_BLK_MISALIGN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 78, 1)

template SD_CSD_READ_BLK_MISALIGN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 77, 1)

template SD_CSD_DSR_IMP*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 76, 1)

template SD_CSD_C_SIZE*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 62, 12)

template SD_CSD_CAPACITY*(resp: untyped): untyped =
  ((SD_CSD_C_SIZE((resp)) + 1) shl (SD_CSD_C_SIZE_MULT((resp)) + 2))

template SD_CSD_V2_C_SIZE*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 48, 22)

template SD_CSD_V2_CAPACITY*(resp: untyped): untyped =
  ((SD_CSD_V2_C_SIZE((resp)) + 1) shl 10)

const
  SD_CSD_V2_BL_LEN* = 0x00000009

template SD_CSD_VDD_R_CURR_MIN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 59, 3)

template SD_CSD_VDD_R_CURR_MAX*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 56, 3)

template SD_CSD_VDD_W_CURR_MIN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 53, 3)

template SD_CSD_VDD_W_CURR_MAX*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 50, 3)

const
  SD_CSD_VDD_RW_CURR_100mA* = 0x00000007
  SD_CSD_VDD_RW_CURR_80mA* = 0x00000006

template SD_CSD_C_SIZE_MULT*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 47, 3)

template SD_CSD_ERASE_BLK_EN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 46, 1)

template SD_CSD_SECTOR_SIZE*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 39, 7)   ##  +1

template SD_CSD_WP_GRP_SIZE*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 32, 7)   ##  +1

template SD_CSD_WP_GRP_ENABLE*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 31, 1)

template SD_CSD_R2W_FACTOR*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 26, 3)

template SD_CSD_WRITE_BL_LEN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 22, 4)

const
  SD_CSD_RW_BL_LEN_2G* = 0x0000000A
  SD_CSD_RW_BL_LEN_1G* = 0x00000009

template SD_CSD_WRITE_BL_PARTIAL*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 21, 1)

template SD_CSD_FILE_FORMAT_GRP*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 15, 1)

template SD_CSD_COPY*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 14, 1)

template SD_CSD_PERM_WRITE_PROTECT*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 13, 1)

template SD_CSD_TMP_WRITE_PROTECT*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 12, 1)

template SD_CSD_FILE_FORMAT*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 10, 2)

##  SD R2 response (CID)

template SD_CID_MID*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 120, 8)

template SD_CID_OID*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 104, 16)

template SD_CID_PNM_CPY*(resp, pnm: untyped): void =
  while true:
    (pnm)[0] = MMC_RSP_BITS((resp), 96, 8)
    (pnm)[1] = MMC_RSP_BITS((resp), 88, 8)
    (pnm)[2] = MMC_RSP_BITS((resp), 80, 8)
    (pnm)[3] = MMC_RSP_BITS((resp), 72, 8)
    (pnm)[4] = MMC_RSP_BITS((resp), 64, 8)
    (pnm)[5] = '\x00'
    if not 0:
      break

template SD_CID_REV*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 56, 8)

template SD_CID_PSN*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 24, 32)

template SD_CID_MDT*(resp: untyped): untyped =
  MMC_RSP_BITS((resp), 8, 12)

##  SCR (SD Configuration Register)

template SCR_STRUCTURE*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 60, 4)

const
  SCR_STRUCTURE_VER_1_0* = 0

template SCR_SD_SPEC*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 56, 4)

const
  SCR_SD_SPEC_VER_1_0* = 0
  SCR_SD_SPEC_VER_1_10* = 1
  SCR_SD_SPEC_VER_2* = 2

template SCR_DATA_STAT_AFTER_ERASE*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 55, 1)

template SCR_SD_SECURITY*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 52, 3)

const
  SCR_SD_SECURITY_NONE* = 0
  SCR_SD_SECURITY_1_0* = 1
  SCR_SD_SECURITY_1_0_2* = 2

template SCR_SD_BUS_WIDTHS*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 48, 4)

const
  SCR_SD_BUS_WIDTHS_1BIT* = (1 shl 0) ##  1bit (DAT0)
  SCR_SD_BUS_WIDTHS_4BIT* = (1 shl 2) ##  4bit (DAT0-3)

template SCR_SD_SPEC3*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 47, 1)

template SCR_EX_SECURITY*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 43, 4)

template SCR_SD_SPEC4*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 42, 1)

template SCR_RESERVED*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 34, 8)

template SCR_CMD_SUPPORT_CMD23*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 33, 1)

template SCR_CMD_SUPPORT_CMD20*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 32, 1)

template SCR_RESERVED2*(scr: untyped): untyped =
  MMC_RSP_BITS((scr), 0, 32)

##  Max supply current in SWITCH_FUNC response (in mA)

template SD_SFUNC_I_MAX*(status: untyped): untyped =
  (MMC_RSP_BITS(cast[ptr uint32]((status)), 496, 16))

##  Supported flags in SWITCH_FUNC response

template SD_SFUNC_SUPPORTED*(status, group: untyped): untyped =
  (MMC_RSP_BITS(cast[ptr uint32]((status)), 400 + (group - 1) * 16, 16))

##  Selected function in SWITCH_FUNC response

template SD_SFUNC_SELECTED*(status, group: untyped): untyped =
  (MMC_RSP_BITS(cast[ptr uint32]((status)), 376 + (group - 1) * 4, 4))

##  Busy flags in SWITCH_FUNC response

template SD_SFUNC_BUSY*(status, group: untyped): untyped =
  (MMC_RSP_BITS(cast[ptr uint32]((status)), 272 + (group - 1) * 16, 16))

##  Version of SWITCH_FUNC response

template SD_SFUNC_VER*(status: untyped): untyped =
  (MMC_RSP_BITS(cast[ptr uint32]((status)), 368, 8))

const
  SD_SFUNC_GROUP_MAX* = 6
  SD_SFUNC_FUNC_MAX* = 15
  SD_ACCESS_MODE* = 1
  SD_ACCESS_MODE_SDR12* = 0
  SD_ACCESS_MODE_SDR25* = 1
  SD_ACCESS_MODE_SDR50* = 2
  SD_ACCESS_MODE_SDR104* = 3
  SD_ACCESS_MODE_DDR50* = 4

## *
##  @brief Extract up to 32 sequential bits from an array of 32-bit words
##
##  Bits within the word are numbered in the increasing order from LSB to MSB.
##
##  As an example, consider 2 32-bit words:
##
##  0x01234567 0x89abcdef
##
##  On a little-endian system, the bytes are stored in memory as follows:
##
##  67 45 23 01 ef cd ab 89
##
##  MMC_RSP_BITS will extact bits as follows:
##
##  start=0  len=4   -> result=0x00000007
##  start=0  len=12  -> result=0x00000567
##  start=28 len=8   -> result=0x000000f0
##  start=59 len=5   -> result=0x00000011
##
##  @param src array of words to extract bits from
##  @param start index of the first bit to extract
##  @param len number of bits to extract, 1 to 32
##  @return 32-bit word where requested bits start from LSB
##

proc MMC_RSP_BITS*(src: ptr uint32; start: cint; len: cint): uint32 {.inline.} =
  var mask: uint32
  var word: csize_t
  var shift: csize_t
  var right: uint32
  var left: uint32
  return (left or right) and mask

##  SD R4 response (IO OCR)

const
  SD_IO_OCR_MEM_READY* = (1 shl 31)

template SD_IO_OCR_NUM_FUNCTIONS*(ocr: untyped): untyped =
  (((ocr) shr 28) and 0x00000007)

const
  SD_IO_OCR_MEM_PRESENT* = (1 shl 27)
  SD_IO_OCR_MASK* = 0x00FFFFF0

##  CMD52 arguments

const
  SD_ARG_CMD52_READ* = (0 shl 31)
  SD_ARG_CMD52_WRITE* = (1 shl 31)
  SD_ARG_CMD52_FUNC_SHIFT* = 28
  SD_ARG_CMD52_FUNC_MASK* = 0x00000007
  SD_ARG_CMD52_EXCHANGE* = (1 shl 27)
  SD_ARG_CMD52_REG_SHIFT* = 9
  SD_ARG_CMD52_REG_MASK* = 0x0001FFFF
  SD_ARG_CMD52_DATA_SHIFT* = 0
  SD_ARG_CMD52_DATA_MASK* = 0x000000FF

template SD_R5_DATA*(resp: untyped): untyped =
  ((resp)[0] and 0x000000FF)

##  CMD53 arguments

const
  SD_ARG_CMD53_READ* = (0 shl 31)
  SD_ARG_CMD53_WRITE* = (1 shl 31)
  SD_ARG_CMD53_FUNC_SHIFT* = 28
  SD_ARG_CMD53_FUNC_MASK* = 0x00000007
  SD_ARG_CMD53_BLOCK_MODE* = (1 shl 27)
  SD_ARG_CMD53_INCREMENT* = (1 shl 26)
  SD_ARG_CMD53_REG_SHIFT* = 9
  SD_ARG_CMD53_REG_MASK* = 0x0001FFFF
  SD_ARG_CMD53_LENGTH_SHIFT* = 0
  SD_ARG_CMD53_LENGTH_MASK* = 0x000001FF
  SD_ARG_CMD53_LENGTH_MAX* = 512

##  Card Common Control Registers (CCCR)

const
  SD_IO_CCCR_START* = 0x00000000
  SD_IO_CCCR_SIZE* = 0x00000100
  SD_IO_CCCR_FN_ENABLE* = 0x00000002
  SD_IO_CCCR_FN_READY* = 0x00000003
  SD_IO_CCCR_INT_ENABLE* = 0x00000004
  SD_IO_CCCR_INT_PENDING* = 0x00000005
  SD_IO_CCCR_CTL* = 0x00000006
  CCCR_CTL_RES* = (1 shl 3)
  SD_IO_CCCR_BUS_WIDTH* = 0x00000007
  CCCR_BUS_WIDTH_1* = (0 shl 0)
  CCCR_BUS_WIDTH_4* = (2 shl 0)
  CCCR_BUS_WIDTH_8* = (3 shl 0)
  CCCR_BUS_WIDTH_ECSI* = (1 shl 5)
  SD_IO_CCCR_CARD_CAP* = 0x00000008
  CCCR_CARD_CAP_LSC* = BIT(6)
  CCCR_CARD_CAP_4BLS* = BIT(7)
  SD_IO_CCCR_CISPTR* = 0x00000009
  SD_IO_CCCR_BLKSIZEL* = 0x00000010
  SD_IO_CCCR_BLKSIZEH* = 0x00000011
  SD_IO_CCCR_HIGHSPEED* = 0x00000013
  CCCR_HIGHSPEED_SUPPORT* = BIT(0)
  CCCR_HIGHSPEED_ENABLE* = BIT(1)

##  Function Basic Registers (FBR)

const
  SD_IO_FBR_START* = 0x00000100
  SD_IO_FBR_SIZE* = 0x00000700

##  Card Information Structure (CIS)

const
  SD_IO_CIS_START* = 0x00001000
  SD_IO_CIS_SIZE* = 0x00017000

##  CIS tuple codes (based on PC Card 16)

const
  CISTPL_CODE_NULL* = 0x00000000
  CISTPL_CODE_DEVICE* = 0x00000001
  CISTPL_CODE_CHKSUM* = 0x00000010
  CISTPL_CODE_VERS1* = 0x00000015
  CISTPL_CODE_ALTSTR* = 0x00000016
  CISTPL_CODE_CONFIG* = 0x0000001A
  CISTPL_CODE_CFTABLE_ENTRY* = 0x0000001B
  CISTPL_CODE_MANFID* = 0x00000020
  CISTPL_CODE_FUNCID* = 0x00000021
  TPLFID_FUNCTION_SDIO* = 0x0000000C
  CISTPL_CODE_FUNCE* = 0x00000022
  CISTPL_CODE_VENDER_BEGIN* = 0x00000080
  CISTPL_CODE_VENDER_END* = 0x0000008F
  CISTPL_CODE_SDIO_STD* = 0x00000091
  CISTPL_CODE_SDIO_EXT* = 0x00000092
  CISTPL_CODE_END* = 0x000000FF

##  Timing

const
  SDMMC_TIMING_LEGACY* = 0
  SDMMC_TIMING_HIGHSPEED* = 1
  SDMMC_TIMING_MMC_DDR52* = 2

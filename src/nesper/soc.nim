##  Copyright 2010-2019 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

const
  PRO_CPU_NUM* = (0)
  APP_CPU_NUM* = (1)

##  Overall memory map

const
  SOC_IROM_LOW* = 0x400D0000
  SOC_IROM_HIGH* = 0x40400000
  SOC_DROM_LOW* = 0x3F400000
  SOC_DROM_HIGH* = 0x3F800000
  SOC_DRAM_LOW* = 0x3FFAE000
  SOC_DRAM_HIGH* = 0x40000000
  SOC_RTC_IRAM_LOW* = 0x400C0000
  SOC_RTC_IRAM_HIGH* = 0x400C2000
  SOC_RTC_DATA_LOW* = 0x50000000
  SOC_RTC_DATA_HIGH* = 0x50002000
  SOC_EXTRAM_DATA_LOW* = 0x3F800000
  SOC_EXTRAM_DATA_HIGH* = 0x3FC00000
  SOC_MAX_CONTIGUOUS_RAM_SIZE* = 0x00400000
  DR_REG_DPORT_BASE* = 0x3FF00000
  DR_REG_AES_BASE* = 0x3FF01000
  DR_REG_RSA_BASE* = 0x3FF02000
  DR_REG_SHA_BASE* = 0x3FF03000
  DR_REG_FLASH_MMU_TABLE_PRO* = 0x3FF10000
  DR_REG_FLASH_MMU_TABLE_APP* = 0x3FF12000
  DR_REG_DPORT_END* = 0x3FF13FFC
  DR_REG_UART_BASE* = 0x3FF40000
  DR_REG_SPI1_BASE* = 0x3FF42000
  DR_REG_SPI0_BASE* = 0x3FF43000
  DR_REG_GPIO_BASE* = 0x3FF44000
  DR_REG_GPIO_SD_BASE* = 0x3FF44F00
  DR_REG_FE2_BASE* = 0x3FF45000
  DR_REG_FE_BASE* = 0x3FF46000
  DR_REG_FRC_TIMER_BASE* = 0x3FF47000
  DR_REG_RTCCNTL_BASE* = 0x3FF48000
  DR_REG_RTCIO_BASE* = 0x3FF48400
  DR_REG_SENS_BASE* = 0x3FF48800
  DR_REG_RTC_I2C_BASE* = 0x3FF48C00
  DR_REG_IO_MUX_BASE* = 0x3FF49000
  DR_REG_HINF_BASE* = 0x3FF4B000
  DR_REG_UHCI1_BASE* = 0x3FF4C000
  DR_REG_I2S_BASE* = 0x3FF4F000
  DR_REG_UART1_BASE* = 0x3FF50000
  DR_REG_BT_BASE* = 0x3FF51000
  DR_REG_I2C_EXT_BASE* = 0x3FF53000
  DR_REG_UHCI0_BASE* = 0x3FF54000
  DR_REG_SLCHOST_BASE* = 0x3FF55000
  DR_REG_RMT_BASE* = 0x3FF56000
  DR_REG_PCNT_BASE* = 0x3FF57000
  DR_REG_SLC_BASE* = 0x3FF58000
  DR_REG_LEDC_BASE* = 0x3FF59000
  DR_REG_EFUSE_BASE* = 0x3FF5A000
  DR_REG_SPI_ENCRYPT_BASE* = 0x3FF5B000
  DR_REG_NRX_BASE* = 0x3FF5CC00
  DR_REG_BB_BASE* = 0x3FF5D000
  DR_REG_PWM_BASE* = 0x3FF5E000
  DR_REG_TIMERGROUP0_BASE* = 0x3FF5F000
  DR_REG_TIMERGROUP1_BASE* = 0x3FF60000
  DR_REG_RTCMEM0_BASE* = 0x3FF61000
  DR_REG_RTCMEM1_BASE* = 0x3FF62000
  DR_REG_RTCMEM2_BASE* = 0x3FF63000
  DR_REG_SPI2_BASE* = 0x3FF64000
  DR_REG_SPI3_BASE* = 0x3FF65000
  DR_REG_SYSCON_BASE* = 0x3FF66000
  DR_REG_APB_CTRL_BASE* = 0x3FF66000
  DR_REG_I2C1_EXT_BASE* = 0x3FF67000
  DR_REG_SDMMC_BASE* = 0x3FF68000
  DR_REG_EMAC_BASE* = 0x3FF69000
  DR_REG_CAN_BASE* = 0x3FF6B000
  DR_REG_PWM1_BASE* = 0x3FF6C000
  DR_REG_I2S1_BASE* = 0x3FF6D000
  DR_REG_UART2_BASE* = 0x3FF6E000
  DR_REG_PWM2_BASE* = 0x3FF6F000
  DR_REG_PWM3_BASE* = 0x3FF70000
  PERIPHS_SPI_ENCRYPT_BASEADDR* = DR_REG_SPI_ENCRYPT_BASE

## Periheral Clock {{

const
  APB_CLK_FREQ* = (80 * 1000000)  ## unit: Hz
  APB_CLK_FREQ_ROM* = (26 * 1000000)
  CPU_CLK_FREQ_ROM* = APB_CLK_FREQ_ROM
  CPU_CLK_FREQ* = APB_CLK_FREQ
  REF_CLK_FREQ* = (1000000)
  UART_CLK_FREQ* = APB_CLK_FREQ
  WDT_CLK_FREQ* = APB_CLK_FREQ
  TIMER_CLK_FREQ* = (80000000 shr 4) ## 80MHz divided by 16
  SPI_CLK_DIV* = 4
  TICKS_PER_US_ROM* = 26
  GPIO_MATRIX_DELAY_NS* = 25

## }}
##  Overall memory map

const
  SOC_DROM_LOW* = 0x3F400000
  SOC_DROM_HIGH* = 0x3F800000
  SOC_IROM_LOW* = 0x400D0000
  SOC_IROM_HIGH* = 0x40400000
  SOC_IROM_MASK_LOW* = 0x40000000
  SOC_IROM_MASK_HIGH* = 0x40070000
  SOC_CACHE_PRO_LOW* = 0x40070000
  SOC_CACHE_PRO_HIGH* = 0x40078000
  SOC_CACHE_APP_LOW* = 0x40078000
  SOC_CACHE_APP_HIGH* = 0x40080000
  SOC_IRAM_LOW* = 0x40080000
  SOC_IRAM_HIGH* = 0x400A0000
  SOC_RTC_IRAM_LOW* = 0x400C0000
  SOC_RTC_IRAM_HIGH* = 0x400C2000
  SOC_RTC_DRAM_LOW* = 0x3FF80000
  SOC_RTC_DRAM_HIGH* = 0x3FF82000
  SOC_RTC_DATA_LOW* = 0x50000000
  SOC_RTC_DATA_HIGH* = 0x50002000

## First and last words of the D/IRAM region, for both the DRAM address as well as the IRAM alias.

const
  SOC_DIRAM_IRAM_LOW* = 0x400A0000
  SOC_DIRAM_IRAM_HIGH* = 0x400BFFFC
  SOC_DIRAM_DRAM_LOW* = 0x3FFE0000
  SOC_DIRAM_DRAM_HIGH* = 0x3FFFFFFC

##  Region of memory accessible via DMA. See esp_ptr_dma_capable().

const
  SOC_DMA_LOW* = 0x3FFAE000
  SOC_DMA_HIGH* = 0x40000000

##  Region of memory that is byte-accessible. See esp_ptr_byte_accessible().

const
  SOC_BYTE_ACCESSIBLE_LOW* = 0x3FF90000
  SOC_BYTE_ACCESSIBLE_HIGH* = 0x40000000

## Region of memory that is internal, as in on the same silicon die as the ESP32 CPUs
## (excluding RTC data region, that's checked separately.) See esp_ptr_internal().

const
  SOC_MEM_INTERNAL_LOW* = 0x3FF90000
  SOC_MEM_INTERNAL_HIGH* = 0x400C2000

## Interrupt hardware source table
## This table is decided by hardware, don't touch this.

const
  ETS_WIFI_MAC_INTR_SOURCE* = 0
  ETS_WIFI_MAC_NMI_SOURCE* = 1
  ETS_WIFI_BB_INTR_SOURCE* = 2
  ETS_BT_MAC_INTR_SOURCE* = 3
  ETS_BT_BB_INTR_SOURCE* = 4
  ETS_BT_BB_NMI_SOURCE* = 5
  ETS_RWBT_INTR_SOURCE* = 6
  ETS_RWBLE_INTR_SOURCE* = 7
  ETS_RWBT_NMI_SOURCE* = 8
  ETS_RWBLE_NMI_SOURCE* = 9
  ETS_SLC0_INTR_SOURCE* = 10
  ETS_SLC1_INTR_SOURCE* = 11
  ETS_UHCI0_INTR_SOURCE* = 12
  ETS_UHCI1_INTR_SOURCE* = 13
  ETS_TG0_T0_LEVEL_INTR_SOURCE* = 14
  ETS_TG0_T1_LEVEL_INTR_SOURCE* = 15
  ETS_TG0_WDT_LEVEL_INTR_SOURCE* = 16
  ETS_TG0_LACT_LEVEL_INTR_SOURCE* = 17
  ETS_TG1_T0_LEVEL_INTR_SOURCE* = 18
  ETS_TG1_T1_LEVEL_INTR_SOURCE* = 19
  ETS_TG1_WDT_LEVEL_INTR_SOURCE* = 20
  ETS_TG1_LACT_LEVEL_INTR_SOURCE* = 21
  ETS_GPIO_INTR_SOURCE* = 22
  ETS_GPIO_NMI_SOURCE* = 23
  ETS_FROM_CPU_INTR0_SOURCE* = 24
  ETS_FROM_CPU_INTR1_SOURCE* = 25
  ETS_FROM_CPU_INTR2_SOURCE* = 26
  ETS_FROM_CPU_INTR3_SOURCE* = 27
  ETS_SPI0_INTR_SOURCE* = 28
  ETS_SPI1_INTR_SOURCE* = 29
  ETS_SPI2_INTR_SOURCE* = 30
  ETS_SPI3_INTR_SOURCE* = 31
  ETS_I2S0_INTR_SOURCE* = 32
  ETS_I2S1_INTR_SOURCE* = 33
  ETS_UART0_INTR_SOURCE* = 34
  ETS_UART1_INTR_SOURCE* = 35
  ETS_UART2_INTR_SOURCE* = 36
  ETS_SDIO_HOST_INTR_SOURCE* = 37
  ETS_ETH_MAC_INTR_SOURCE* = 38
  ETS_PWM0_INTR_SOURCE* = 39
  ETS_PWM1_INTR_SOURCE* = 40
  ETS_PWM2_INTR_SOURCE* = 41
  ETS_PWM3_INTR_SOURCE* = 42
  ETS_LEDC_INTR_SOURCE* = 43
  ETS_EFUSE_INTR_SOURCE* = 44
  ETS_CAN_INTR_SOURCE* = 45
  ETS_RTC_CORE_INTR_SOURCE* = 46
  ETS_RMT_INTR_SOURCE* = 47
  ETS_PCNT_INTR_SOURCE* = 48
  ETS_I2C_EXT0_INTR_SOURCE* = 49
  ETS_I2C_EXT1_INTR_SOURCE* = 50
  ETS_RSA_INTR_SOURCE* = 51
  ETS_SPI1_DMA_INTR_SOURCE* = 52
  ETS_SPI2_DMA_INTR_SOURCE* = 53
  ETS_SPI3_DMA_INTR_SOURCE* = 54
  ETS_WDT_INTR_SOURCE* = 55
  ETS_TIMER1_INTR_SOURCE* = 56
  ETS_TIMER2_INTR_SOURCE* = 57
  ETS_TG0_T0_EDGE_INTR_SOURCE* = 58
  ETS_TG0_T1_EDGE_INTR_SOURCE* = 59
  ETS_TG0_WDT_EDGE_INTR_SOURCE* = 60
  ETS_TG0_LACT_EDGE_INTR_SOURCE* = 61
  ETS_TG1_T0_EDGE_INTR_SOURCE* = 62
  ETS_TG1_T1_EDGE_INTR_SOURCE* = 63
  ETS_TG1_WDT_EDGE_INTR_SOURCE* = 64
  ETS_TG1_LACT_EDGE_INTR_SOURCE* = 65
  ETS_MMU_IA_INTR_SOURCE* = 66
  ETS_MPU_IA_INTR_SOURCE* = 67
  ETS_CACHE_IA_INTR_SOURCE* = 68

## interrupt cpu using table, Please see the core-isa.h
## ************************************************************************************************************
##       Intr num                Level           Type                    PRO CPU usage           APP CPU uasge
##       0                       1               extern level            WMAC                    Reserved
##       1                       1               extern level            BT/BLE Host HCI DMA     BT/BLE Host HCI DMA
##       2                       1               extern level
##       3                       1               extern level
##       4                       1               extern level            WBB
##       5                       1               extern level            BT/BLE Controller       BT/BLE Controller
##       6                       1               timer                   FreeRTOS Tick(L1)       FreeRTOS Tick(L1)
##       7                       1               software                BT/BLE VHCI             BT/BLE VHCI
##       8                       1               extern level            BT/BLE BB(RX/TX)        BT/BLE BB(RX/TX)
##       9                       1               extern level
##       10                      1               extern edge
##       11                      3               profiling
##       12                      1               extern level
##       13                      1               extern level
##       14                      7               nmi                     Reserved                Reserved
##       15                      3               timer                   FreeRTOS Tick(L3)       FreeRTOS Tick(L3)
##       16                      5               timer
##       17                      1               extern level
##       18                      1               extern level
##       19                      2               extern level
##       20                      2               extern level
##       21                      2               extern level
##       22                      3               extern edge
##       23                      3               extern level
##       24                      4               extern level            TG1_WDT
##       25                      4               extern level            CACHEERR
##       26                      5               extern level
##       27                      3               extern level            Reserved                Reserved
##       28                      4               extern edge             DPORT ACCESS            DPORT ACCESS
##       29                      3               software                Reserved                Reserved
##       30                      4               extern edge             Reserved                Reserved
##       31                      5               extern level
## ************************************************************************************************************
##
## CPU0 Interrupt number reserved, not touch this.

const
  ETS_WMAC_INUM* = 0
  ETS_BT_HOST_INUM* = 1
  ETS_WBB_INUM* = 4
  ETS_TG0_T1_INUM* = 10
  ETS_FRC1_INUM* = 22
  ETS_T1_WDT_INUM* = 24
  ETS_CACHEERR_INUM* = 25
  ETS_DPORT_INUM* = 28

## CPU0 Interrupt number used in ROM, should be cancelled in SDK

const
  ETS_SLC_INUM* = 1
  ETS_UART0_INUM* = 5
  ETS_UART1_INUM* = 5

## Other interrupt number should be managed by the user
## Invalid interrupt for number interrupt matrix

const
  ETS_INVALID_INUM* = 6

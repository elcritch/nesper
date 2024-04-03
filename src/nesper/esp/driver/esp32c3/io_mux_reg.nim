##
## //
##  SPDX-FileCopyrightText: 2020-2021 Espressif Systems (Shanghai) CO LTD
## //
##
## //
##  SPDX-License-Identifier: Apache-2.0
## //
##
##

    
const hdr = "soc/io_mux_reg.h"

var SLP_OE* {.importcpp: "SLP_OE", header: hdr.}: int
var SLP_OE_M* {.importcpp: "SLP_OE_M", header: hdr.}: int
var SLP_OE_V* {.importcpp: "SLP_OE_V", header: hdr.}: int
var SLP_OE_S* {.importcpp: "SLP_OE_S", header: hdr.}: int
##  Pin used for wakeup from sleep
##
var SLP_SEL* {.importcpp: "SLP_SEL", header: hdr.}: int
var SLP_SEL_M* {.importcpp: "SLP_SEL_M", header: hdr.}: int
var SLP_SEL_V* {.importcpp: "SLP_SEL_V", header: hdr.}: int
var SLP_SEL_S* {.importcpp: "SLP_SEL_S", header: hdr.}: int
##  Pulldown enable in sleep mode
##
var SLP_PD* {.importcpp: "SLP_PD", header: hdr.}: int
var SLP_PD_M* {.importcpp: "SLP_PD_M", header: hdr.}: int
var SLP_PD_V* {.importcpp: "SLP_PD_V", header: hdr.}: int
var SLP_PD_S* {.importcpp: "SLP_PD_S", header: hdr.}: int
##  Pullup enable in sleep mode
##
var SLP_PU* {.importcpp: "SLP_PU", header: hdr.}: int
var SLP_PU_M* {.importcpp: "SLP_PU_M", header: hdr.}: int
var SLP_PU_V* {.importcpp: "SLP_PU_V", header: hdr.}: int
var SLP_PU_S* {.importcpp: "SLP_PU_S", header: hdr.}: int
##  Input enable in sleep mode
##
var SLP_IE* {.importcpp: "SLP_IE", header: hdr.}: int
var SLP_IE_M* {.importcpp: "SLP_IE_M", header: hdr.}: int
var SLP_IE_V* {.importcpp: "SLP_IE_V", header: hdr.}: int
var SLP_IE_S* {.importcpp: "SLP_IE_S", header: hdr.}: int
##  Drive strength in sleep mode
##
var SLP_DRV* {.importcpp: "SLP_DRV", header: hdr.}: int
var SLP_DRV_M* {.importcpp: "SLP_DRV_M", header: hdr.}: int
var SLP_DRV_V* {.importcpp: "SLP_DRV_V", header: hdr.}: int
var SLP_DRV_S* {.importcpp: "SLP_DRV_S", header: hdr.}: int
##  Pulldown enable
##
var FUN_PD* {.importcpp: "FUN_PD", header: hdr.}: int
var FUN_PD_M* {.importcpp: "FUN_PD_M", header: hdr.}: int
var FUN_PD_V* {.importcpp: "FUN_PD_V", header: hdr.}: int
var FUN_PD_S* {.importcpp: "FUN_PD_S", header: hdr.}: int
##  Pullup enable
##
var FUN_PU* {.importcpp: "FUN_PU", header: hdr.}: int
var FUN_PU_M* {.importcpp: "FUN_PU_M", header: hdr.}: int
var FUN_PU_V* {.importcpp: "FUN_PU_V", header: hdr.}: int
var FUN_PU_S* {.importcpp: "FUN_PU_S", header: hdr.}: int
##  Input enable
##
var FUN_IE* {.importcpp: "FUN_IE", header: hdr.}: int
var FUN_IE_M* {.importcpp: "FUN_IE_M", header: hdr.}: int
var FUN_IE_V* {.importcpp: "FUN_IE_V", header: hdr.}: int
var FUN_IE_S* {.importcpp: "FUN_IE_S", header: hdr.}: int
##  Drive strength
##
var FUN_DRV* {.importcpp: "FUN_DRV", header: hdr.}: int
var FUN_DRV_M* {.importcpp: "FUN_DRV_M", header: hdr.}: int
var FUN_DRV_V* {.importcpp: "FUN_DRV_V", header: hdr.}: int
var FUN_DRV_S* {.importcpp: "FUN_DRV_S", header: hdr.}: int
##  Function select (possible values are defined for each pin as FUNC_pinname_function below)
##
var MCU_SEL* {.importcpp: "MCU_SEL", header: hdr.}: int
var MCU_SEL_M* {.importcpp: "MCU_SEL_M", header: hdr.}: int
var MCU_SEL_V* {.importcpp: "MCU_SEL_V", header: hdr.}: int
var MCU_SEL_S* {.importcpp: "MCU_SEL_S", header: hdr.}: int
##  Pin filter (Pulse width shorter than 2 clock cycles will be filtered out)
##
var FILTER_EN* {.importcpp: "FILTER_EN", header: hdr.}: int
var FILTER_EN_M* {.importcpp: "FILTER_EN_M", header: hdr.}: int
var FILTER_EN_V* {.importcpp: "FILTER_EN_V", header: hdr.}: int
var FILTER_EN_S* {.importcpp: "FILTER_EN_S", header: hdr.}: int
# proc PIN_SLP_INPUT_ENABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_INPUT_ENABLE", header: hdr.}
# proc PIN_SLP_INPUT_DISABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_INPUT_DISABLE", header: hdr.}
# proc PIN_SLP_OUTPUT_ENABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_OUTPUT_ENABLE", header: hdr.}
# proc PIN_SLP_OUTPUT_DISABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_OUTPUT_DISABLE", header: hdr.}
# proc PIN_SLP_PULLUP_ENABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_PULLUP_ENABLE", header: hdr.}
# proc PIN_SLP_PULLUP_DISABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_PULLUP_DISABLE", header: hdr.}
# proc PIN_SLP_PULLDOWN_ENABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_PULLDOWN_ENABLE", header: hdr.}
# proc PIN_SLP_PULLDOWN_DISABLE*(PIN_NAME: untyped) {.
#     importcpp: "PIN_SLP_PULLDOWN_DISABLE", header: hdr.}
# proc PIN_SLP_SEL_ENABLE*(PIN_NAME: untyped) {.importcpp: "PIN_SLP_SEL_ENABLE",
#     header: hdr.}
# proc PIN_SLP_SEL_DISABLE*(PIN_NAME: untyped) {.importcpp: "PIN_SLP_SEL_DISABLE",
#     header: hdr.}
# proc PIN_INPUT_ENABLE*(PIN_NAME: untyped) {.importcpp: "PIN_INPUT_ENABLE",
#     header: hdr.}
# proc PIN_INPUT_DISABLE*(PIN_NAME: untyped) {.importcpp: "PIN_INPUT_DISABLE",
#     header: hdr.}
# proc PIN_SET_DRV*(PIN_NAME: untyped; drv: untyped) {.importcpp: "PIN_SET_DRV",
#     header: hdr.}
# proc PIN_PULLUP_DIS*(PIN_NAME: untyped) {.importcpp: "PIN_PULLUP_DIS", header: hdr.}
# proc PIN_PULLUP_EN*(PIN_NAME: untyped) {.importcpp: "PIN_PULLUP_EN", header: hdr.}
# proc PIN_PULLDWN_DIS*(PIN_NAME: untyped) {.importcpp: "PIN_PULLDWN_DIS",
#     header: hdr.}
# proc PIN_PULLDWN_EN*(PIN_NAME: untyped) {.importcpp: "PIN_PULLDWN_EN", header: hdr.}
# proc PIN_FUNC_SELECT*(PIN_NAME: untyped; FUNC: untyped) {.
#     importcpp: "PIN_FUNC_SELECT", header: hdr.}
# proc PIN_FILTER_EN*(PIN_NAME: untyped) {.importcpp: "PIN_FILTER_EN", header: hdr.}
# proc PIN_FILTER_DIS*(PIN_NAME: untyped) {.importcpp: "PIN_FILTER_DIS", header: hdr.}
var IO_MUX_GPIO0_REG* {.importcpp: "IO_MUX_GPIO0_REG", header: hdr.}: int
var IO_MUX_GPIO1_REG* {.importcpp: "IO_MUX_GPIO1_REG", header: hdr.}: int
var IO_MUX_GPIO2_REG* {.importcpp: "IO_MUX_GPIO2_REG", header: hdr.}: int
var IO_MUX_GPIO3_REG* {.importcpp: "IO_MUX_GPIO3_REG", header: hdr.}: int
var IO_MUX_GPIO4_REG* {.importcpp: "IO_MUX_GPIO4_REG", header: hdr.}: int
var IO_MUX_GPIO5_REG* {.importcpp: "IO_MUX_GPIO5_REG", header: hdr.}: int
var IO_MUX_GPIO6_REG* {.importcpp: "IO_MUX_GPIO6_REG", header: hdr.}: int
var IO_MUX_GPIO7_REG* {.importcpp: "IO_MUX_GPIO7_REG", header: hdr.}: int
var IO_MUX_GPIO8_REG* {.importcpp: "IO_MUX_GPIO8_REG", header: hdr.}: int
var IO_MUX_GPIO9_REG* {.importcpp: "IO_MUX_GPIO9_REG", header: hdr.}: int
var IO_MUX_GPIO10_REG* {.importcpp: "IO_MUX_GPIO10_REG", header: hdr.}: int
var IO_MUX_GPIO11_REG* {.importcpp: "IO_MUX_GPIO11_REG", header: hdr.}: int
var IO_MUX_GPIO12_REG* {.importcpp: "IO_MUX_GPIO12_REG", header: hdr.}: int
var IO_MUX_GPIO13_REG* {.importcpp: "IO_MUX_GPIO13_REG", header: hdr.}: int
var IO_MUX_GPIO14_REG* {.importcpp: "IO_MUX_GPIO14_REG", header: hdr.}: int
var IO_MUX_GPIO15_REG* {.importcpp: "IO_MUX_GPIO15_REG", header: hdr.}: int
var IO_MUX_GPIO16_REG* {.importcpp: "IO_MUX_GPIO16_REG", header: hdr.}: int
var IO_MUX_GPIO17_REG* {.importcpp: "IO_MUX_GPIO17_REG", header: hdr.}: int
var IO_MUX_GPIO18_REG* {.importcpp: "IO_MUX_GPIO18_REG", header: hdr.}: int
var IO_MUX_GPIO19_REG* {.importcpp: "IO_MUX_GPIO19_REG", header: hdr.}: int
var IO_MUX_GPIO20_REG* {.importcpp: "IO_MUX_GPIO20_REG", header: hdr.}: int
var IO_MUX_GPIO21_REG* {.importcpp: "IO_MUX_GPIO21_REG", header: hdr.}: int
##  Value to set in IO Mux to use a pin as GPIO.
##
var PIN_FUNC_GPIO* {.importcpp: "PIN_FUNC_GPIO", header: hdr.}: int
# proc GPIO_PAD_PULLUP*(num: untyped) {.importcpp: "GPIO_PAD_PULLUP", header: hdr.}
# proc GPIO_PAD_PULLDOWN*(num: untyped) {.importcpp: "GPIO_PAD_PULLDOWN", header: hdr.}
# proc GPIO_PAD_SET_DRV*(num: untyped; drv: untyped) {.importcpp: "GPIO_PAD_SET_DRV",
#     header: hdr.}
var SPI_HD_GPIO_NUM* {.importcpp: "SPI_HD_GPIO_NUM", header: hdr.}: int
var SPI_WP_GPIO_NUM* {.importcpp: "SPI_WP_GPIO_NUM", header: hdr.}: int
var SPI_CS0_GPIO_NUM* {.importcpp: "SPI_CS0_GPIO_NUM", header: hdr.}: int
var SPI_CLK_GPIO_NUM* {.importcpp: "SPI_CLK_GPIO_NUM", header: hdr.}: int
var SPI_D_GPIO_NUM* {.importcpp: "SPI_D_GPIO_NUM", header: hdr.}: int
var SPI_Q_GPIO_NUM* {.importcpp: "SPI_Q_GPIO_NUM", header: hdr.}: int
var SD_CLK_GPIO_NUM* {.importcpp: "SD_CLK_GPIO_NUM", header: hdr.}: int
var SD_CMD_GPIO_NUM* {.importcpp: "SD_CMD_GPIO_NUM", header: hdr.}: int
var SD_DATA0_GPIO_NUM* {.importcpp: "SD_DATA0_GPIO_NUM", header: hdr.}: int
var SD_DATA1_GPIO_NUM* {.importcpp: "SD_DATA1_GPIO_NUM", header: hdr.}: int
var SD_DATA2_GPIO_NUM* {.importcpp: "SD_DATA2_GPIO_NUM", header: hdr.}: int
var SD_DATA3_GPIO_NUM* {.importcpp: "SD_DATA3_GPIO_NUM", header: hdr.}: int
var USB_DM_GPIO_NUM* {.importcpp: "USB_DM_GPIO_NUM", header: hdr.}: int
var USB_DP_GPIO_NUM* {.importcpp: "USB_DP_GPIO_NUM", header: hdr.}: int
var MAX_RTC_GPIO_NUM* {.importcpp: "MAX_RTC_GPIO_NUM", header: hdr.}: int
var MAX_PAD_GPIO_NUM* {.importcpp: "MAX_PAD_GPIO_NUM", header: hdr.}: int
var MAX_GPIO_NUM* {.importcpp: "MAX_GPIO_NUM", header: hdr.}: int
var REG_IO_MUX_BASE* {.importcpp: "REG_IO_MUX_BASE", header: hdr.}: int
var PIN_CTRL* {.importcpp: "PIN_CTRL", header: hdr.}: int
var PAD_POWER_SEL* {.importcpp: "PAD_POWER_SEL", header: hdr.}: int
var PAD_POWER_SEL_V* {.importcpp: "PAD_POWER_SEL_V", header: hdr.}: int
var PAD_POWER_SEL_M* {.importcpp: "PAD_POWER_SEL_M", header: hdr.}: int
var PAD_POWER_SEL_S* {.importcpp: "PAD_POWER_SEL_S", header: hdr.}: int
var PAD_POWER_SWITCH_DELAY* {.importcpp: "PAD_POWER_SWITCH_DELAY", header: hdr.}: int
var PAD_POWER_SWITCH_DELAY_V* {.importcpp: "PAD_POWER_SWITCH_DELAY_V", header: hdr.}: int
var PAD_POWER_SWITCH_DELAY_M* {.importcpp: "PAD_POWER_SWITCH_DELAY_M", header: hdr.}: int
var PAD_POWER_SWITCH_DELAY_S* {.importcpp: "PAD_POWER_SWITCH_DELAY_S", header: hdr.}: int
var CLK_OUT3* {.importcpp: "CLK_OUT3", header: hdr.}: int
var CLK_OUT3_V* {.importcpp: "CLK_OUT3_V", header: hdr.}: int
var CLK_OUT3_S* {.importcpp: "CLK_OUT3_S", header: hdr.}: int
var CLK_OUT3_M* {.importcpp: "CLK_OUT3_M", header: hdr.}: int
var CLK_OUT2* {.importcpp: "CLK_OUT2", header: hdr.}: int
var CLK_OUT2_V* {.importcpp: "CLK_OUT2_V", header: hdr.}: int
var CLK_OUT2_S* {.importcpp: "CLK_OUT2_S", header: hdr.}: int
var CLK_OUT2_M* {.importcpp: "CLK_OUT2_M", header: hdr.}: int
var CLK_OUT1* {.importcpp: "CLK_OUT1", header: hdr.}: int
var CLK_OUT1_V* {.importcpp: "CLK_OUT1_V", header: hdr.}: int
var CLK_OUT1_S* {.importcpp: "CLK_OUT1_S", header: hdr.}: int
var CLK_OUT1_M* {.importcpp: "CLK_OUT1_M", header: hdr.}: int
var PERIPHS_IO_MUX_XTAL_32K_P_U* {.importcpp: "PERIPHS_IO_MUX_XTAL_32K_P_U",
                                header: hdr.}: int
var FUNC_XTAL_32K_P_GPIO0* {.importcpp: "FUNC_XTAL_32K_P_GPIO0", header: hdr.}: int
var FUNC_XTAL_32K_P_GPIO0_0* {.importcpp: "FUNC_XTAL_32K_P_GPIO0_0", header: hdr.}: int
var PERIPHS_IO_MUX_XTAL_32K_N_U* {.importcpp: "PERIPHS_IO_MUX_XTAL_32K_N_U",
                                header: hdr.}: int
var FUNC_XTAL_32K_N_GPIO1* {.importcpp: "FUNC_XTAL_32K_N_GPIO1", header: hdr.}: int
var FUNC_XTAL_32K_N_GPIO1_0* {.importcpp: "FUNC_XTAL_32K_N_GPIO1_0", header: hdr.}: int
var PERIPHS_IO_MUX_GPIO2_U* {.importcpp: "PERIPHS_IO_MUX_GPIO2_U", header: hdr.}: int
var FUNC_GPIO2_FSPIQ* {.importcpp: "FUNC_GPIO2_FSPIQ", header: hdr.}: int
var FUNC_GPIO2_GPIO2* {.importcpp: "FUNC_GPIO2_GPIO2", header: hdr.}: int
var FUNC_GPIO2_GPIO2_0* {.importcpp: "FUNC_GPIO2_GPIO2_0", header: hdr.}: int
var PERIPHS_IO_MUX_GPIO3_U* {.importcpp: "PERIPHS_IO_MUX_GPIO3_U", header: hdr.}: int
var FUNC_GPIO3_GPIO3* {.importcpp: "FUNC_GPIO3_GPIO3", header: hdr.}: int
var FUNC_GPIO3_GPIO3_0* {.importcpp: "FUNC_GPIO3_GPIO3_0", header: hdr.}: int
var PERIPHS_IO_MUX_MTMS_U* {.importcpp: "PERIPHS_IO_MUX_MTMS_U", header: hdr.}: int
var FUNC_MTMS_FSPIHD* {.importcpp: "FUNC_MTMS_FSPIHD", header: hdr.}: int
var FUNC_MTMS_GPIO4* {.importcpp: "FUNC_MTMS_GPIO4", header: hdr.}: int
var FUNC_MTMS_MTMS* {.importcpp: "FUNC_MTMS_MTMS", header: hdr.}: int
var PERIPHS_IO_MUX_MTDI_U* {.importcpp: "PERIPHS_IO_MUX_MTDI_U", header: hdr.}: int
var FUNC_MTDI_FSPIWP* {.importcpp: "FUNC_MTDI_FSPIWP", header: hdr.}: int
var FUNC_MTDI_GPIO5* {.importcpp: "FUNC_MTDI_GPIO5", header: hdr.}: int
var FUNC_MTDI_MTDI* {.importcpp: "FUNC_MTDI_MTDI", header: hdr.}: int
var PERIPHS_IO_MUX_MTCK_U* {.importcpp: "PERIPHS_IO_MUX_MTCK_U", header: hdr.}: int
var FUNC_MTCK_FSPICLK* {.importcpp: "FUNC_MTCK_FSPICLK", header: hdr.}: int
var FUNC_MTCK_GPIO6* {.importcpp: "FUNC_MTCK_GPIO6", header: hdr.}: int
var FUNC_MTCK_MTCK* {.importcpp: "FUNC_MTCK_MTCK", header: hdr.}: int
var PERIPHS_IO_MUX_MTDO_U* {.importcpp: "PERIPHS_IO_MUX_MTDO_U", header: hdr.}: int
var FUNC_MTDO_FSPID* {.importcpp: "FUNC_MTDO_FSPID", header: hdr.}: int
var FUNC_MTDO_GPIO7* {.importcpp: "FUNC_MTDO_GPIO7", header: hdr.}: int
var FUNC_MTDO_MTDO* {.importcpp: "FUNC_MTDO_MTDO", header: hdr.}: int
var PERIPHS_IO_MUX_GPIO8_U* {.importcpp: "PERIPHS_IO_MUX_GPIO8_U", header: hdr.}: int
var FUNC_GPIO8_GPIO8* {.importcpp: "FUNC_GPIO8_GPIO8", header: hdr.}: int
var FUNC_GPIO8_GPIO8_0* {.importcpp: "FUNC_GPIO8_GPIO8_0", header: hdr.}: int
var PERIPHS_IO_MUX_GPIO9_U* {.importcpp: "PERIPHS_IO_MUX_GPIO9_U", header: hdr.}: int
var FUNC_GPIO9_GPIO9* {.importcpp: "FUNC_GPIO9_GPIO9", header: hdr.}: int
var FUNC_GPIO9_GPIO9_0* {.importcpp: "FUNC_GPIO9_GPIO9_0", header: hdr.}: int
var PERIPHS_IO_MUX_GPIO10_U* {.importcpp: "PERIPHS_IO_MUX_GPIO10_U", header: hdr.}: int
var FUNC_GPIO10_FSPICS0* {.importcpp: "FUNC_GPIO10_FSPICS0", header: hdr.}: int
var FUNC_GPIO10_GPIO10* {.importcpp: "FUNC_GPIO10_GPIO10", header: hdr.}: int
var FUNC_GPIO10_GPIO10_0* {.importcpp: "FUNC_GPIO10_GPIO10_0", header: hdr.}: int
var PERIPHS_IO_MUX_VDD_SPI_U* {.importcpp: "PERIPHS_IO_MUX_VDD_SPI_U", header: hdr.}: int
var FUNC_VDD_SPI_GPIO11* {.importcpp: "FUNC_VDD_SPI_GPIO11", header: hdr.}: int
var FUNC_VDD_SPI_GPIO11_0* {.importcpp: "FUNC_VDD_SPI_GPIO11_0", header: hdr.}: int
var PERIPHS_IO_MUX_SPIHD_U* {.importcpp: "PERIPHS_IO_MUX_SPIHD_U", header: hdr.}: int
var FUNC_SPIHD_GPIO12* {.importcpp: "FUNC_SPIHD_GPIO12", header: hdr.}: int
var FUNC_SPIHD_SPIHD* {.importcpp: "FUNC_SPIHD_SPIHD", header: hdr.}: int
var PERIPHS_IO_MUX_SPIWP_U* {.importcpp: "PERIPHS_IO_MUX_SPIWP_U", header: hdr.}: int
var FUNC_SPIWP_GPIO13* {.importcpp: "FUNC_SPIWP_GPIO13", header: hdr.}: int
var FUNC_SPIWP_SPIWP* {.importcpp: "FUNC_SPIWP_SPIWP", header: hdr.}: int
var PERIPHS_IO_MUX_SPICS0_U* {.importcpp: "PERIPHS_IO_MUX_SPICS0_U", header: hdr.}: int
var FUNC_SPICS0_GPIO14* {.importcpp: "FUNC_SPICS0_GPIO14", header: hdr.}: int
var FUNC_SPICS0_SPICS0* {.importcpp: "FUNC_SPICS0_SPICS0", header: hdr.}: int
var PERIPHS_IO_MUX_SPICLK_U* {.importcpp: "PERIPHS_IO_MUX_SPICLK_U", header: hdr.}: int
var FUNC_SPICLK_GPIO15* {.importcpp: "FUNC_SPICLK_GPIO15", header: hdr.}: int
var FUNC_SPICLK_SPICLK* {.importcpp: "FUNC_SPICLK_SPICLK", header: hdr.}: int
var PERIPHS_IO_MUX_SPID_U* {.importcpp: "PERIPHS_IO_MUX_SPID_U", header: hdr.}: int
var FUNC_SPID_GPIO16* {.importcpp: "FUNC_SPID_GPIO16", header: hdr.}: int
var FUNC_SPID_SPID* {.importcpp: "FUNC_SPID_SPID", header: hdr.}: int
var PERIPHS_IO_MUX_SPIQ_U* {.importcpp: "PERIPHS_IO_MUX_SPIQ_U", header: hdr.}: int
var FUNC_SPIQ_GPIO17* {.importcpp: "FUNC_SPIQ_GPIO17", header: hdr.}: int
var FUNC_SPIQ_SPIQ* {.importcpp: "FUNC_SPIQ_SPIQ", header: hdr.}: int
var PERIPHS_IO_MUX_GPIO18_U* {.importcpp: "PERIPHS_IO_MUX_GPIO18_U", header: hdr.}: int
var FUNC_GPIO18_GPIO18* {.importcpp: "FUNC_GPIO18_GPIO18", header: hdr.}: int
var FUNC_GPIO18_GPIO18_0* {.importcpp: "FUNC_GPIO18_GPIO18_0", header: hdr.}: int
var PERIPHS_IO_MUX_GPIO19_U* {.importcpp: "PERIPHS_IO_MUX_GPIO19_U", header: hdr.}: int
var FUNC_GPIO19_GPIO19* {.importcpp: "FUNC_GPIO19_GPIO19", header: hdr.}: int
var FUNC_GPIO19_GPIO19_0* {.importcpp: "FUNC_GPIO19_GPIO19_0", header: hdr.}: int
var PERIPHS_IO_MUX_U0RXD_U* {.importcpp: "PERIPHS_IO_MUX_U0RXD_U", header: hdr.}: int
var FUNC_U0RXD_GPIO20* {.importcpp: "FUNC_U0RXD_GPIO20", header: hdr.}: int
var FUNC_U0RXD_U0RXD* {.importcpp: "FUNC_U0RXD_U0RXD", header: hdr.}: int
var PERIPHS_IO_MUX_U0TXD_U* {.importcpp: "PERIPHS_IO_MUX_U0TXD_U", header: hdr.}: int
var FUNC_U0TXD_GPIO21* {.importcpp: "FUNC_U0TXD_GPIO21", header: hdr.}: int
var FUNC_U0TXD_U0TXD* {.importcpp: "FUNC_U0TXD_U0TXD", header: hdr.}: int
var IO_MUX_DATE_REG* {.importcpp: "IO_MUX_DATE_REG", header: hdr.}: int
var IO_MUX_DATE* {.importcpp: "IO_MUX_DATE", header: hdr.}: int
var IO_MUX_DATE_S* {.importcpp: "IO_MUX_DATE_S", header: hdr.}: int
var IO_MUX_DATE_VERSION* {.importcpp: "IO_MUX_DATE_VERSION", header: hdr.}: int


#  The following are the bit fields for PERIPHS_IO_MUX_x_U registers 
#  Output enable in sleep mode 
var SLP_OE* {.importc: "SLP_OE", header: "io_mux_reg.h".}: int  # (BIT(0))
var SLP_OE_M* {.importc: "SLP_OE_M", header: "io_mux_reg.h".}: int  # (BIT(0))
var SLP_OE_V* {.importc: "SLP_OE_V", header: "io_mux_reg.h".}: int  # 1
var SLP_OE_S* {.importc: "SLP_OE_S", header: "io_mux_reg.h".}: int  # 0
#  Pin used for wakeup from sleep 
var SLP_SEL* {.importc: "SLP_SEL", header: "io_mux_reg.h".}: int  # (BIT(1))
var SLP_SEL_M* {.importc: "SLP_SEL_M", header: "io_mux_reg.h".}: int  # (BIT(1))
var SLP_SEL_V* {.importc: "SLP_SEL_V", header: "io_mux_reg.h".}: int  # 1
var SLP_SEL_S* {.importc: "SLP_SEL_S", header: "io_mux_reg.h".}: int  # 1
#  Pulldown enable in sleep mode 
var SLP_PD* {.importc: "SLP_PD", header: "io_mux_reg.h".}: int  # (BIT(2))
var SLP_PD_M* {.importc: "SLP_PD_M", header: "io_mux_reg.h".}: int  # (BIT(2))
var SLP_PD_V* {.importc: "SLP_PD_V", header: "io_mux_reg.h".}: int  # 1
var SLP_PD_S* {.importc: "SLP_PD_S", header: "io_mux_reg.h".}: int  # 2
#  Pullup enable in sleep mode 
var SLP_PU* {.importc: "SLP_PU", header: "io_mux_reg.h".}: int  # (BIT(3))
var SLP_PU_M* {.importc: "SLP_PU_M", header: "io_mux_reg.h".}: int  # (BIT(3))
var SLP_PU_V* {.importc: "SLP_PU_V", header: "io_mux_reg.h".}: int  # 1
var SLP_PU_S* {.importc: "SLP_PU_S", header: "io_mux_reg.h".}: int  # 3
#  Input enable in sleep mode 
var SLP_IE* {.importc: "SLP_IE", header: "io_mux_reg.h".}: int  # (BIT(4))
var SLP_IE_M* {.importc: "SLP_IE_M", header: "io_mux_reg.h".}: int  # (BIT(4))
var SLP_IE_V* {.importc: "SLP_IE_V", header: "io_mux_reg.h".}: int  # 1
var SLP_IE_S* {.importc: "SLP_IE_S", header: "io_mux_reg.h".}: int  # 4
#  Drive strength in sleep mode 
var SLP_DRV* {.importc: "SLP_DRV", header: "io_mux_reg.h".}: int  # 0x3
var SLP_DRV_M* {.importc: "SLP_DRV_M", header: "io_mux_reg.h".}: int  # (SLP_DRV_V << SLP_DRV_S)
var SLP_DRV_V* {.importc: "SLP_DRV_V", header: "io_mux_reg.h".}: int  # 0x3
var SLP_DRV_S* {.importc: "SLP_DRV_S", header: "io_mux_reg.h".}: int  # 5
#  Pulldown enable 
var FUN_PD* {.importc: "FUN_PD", header: "io_mux_reg.h".}: int  # (BIT(7))
var FUN_PD_M* {.importc: "FUN_PD_M", header: "io_mux_reg.h".}: int  # (BIT(7))
var FUN_PD_V* {.importc: "FUN_PD_V", header: "io_mux_reg.h".}: int  # 1
var FUN_PD_S* {.importc: "FUN_PD_S", header: "io_mux_reg.h".}: int  # 7
#  Pullup enable 
var FUN_PU* {.importc: "FUN_PU", header: "io_mux_reg.h".}: int  # (BIT(8))
var FUN_PU_M* {.importc: "FUN_PU_M", header: "io_mux_reg.h".}: int  # (BIT(8))
var FUN_PU_V* {.importc: "FUN_PU_V", header: "io_mux_reg.h".}: int  # 1
var FUN_PU_S* {.importc: "FUN_PU_S", header: "io_mux_reg.h".}: int  # 8
#  Input enable 
var FUN_IE* {.importc: "FUN_IE", header: "io_mux_reg.h".}: int  # (BIT(9))
var FUN_IE_M* {.importc: "FUN_IE_M", header: "io_mux_reg.h".}: int  # (FUN_IE_V << FUN_IE_S)
var FUN_IE_V* {.importc: "FUN_IE_V", header: "io_mux_reg.h".}: int  # 1
var FUN_IE_S* {.importc: "FUN_IE_S", header: "io_mux_reg.h".}: int  # 9
#  Drive strength 
var FUN_DRV* {.importc: "FUN_DRV", header: "io_mux_reg.h".}: int  # 0x3
var FUN_DRV_M* {.importc: "FUN_DRV_M", header: "io_mux_reg.h".}: int  # (FUN_DRV_V << FUN_DRV_S)
var FUN_DRV_V* {.importc: "FUN_DRV_V", header: "io_mux_reg.h".}: int  # 0x3
var FUN_DRV_S* {.importc: "FUN_DRV_S", header: "io_mux_reg.h".}: int  # 10
#  Function select (possible values are defined for each pin as FUNC_pinname_function below) 
var MCU_SEL* {.importc: "MCU_SEL", header: "io_mux_reg.h".}: int  # 0x7
var MCU_SEL_M* {.importc: "MCU_SEL_M", header: "io_mux_reg.h".}: int  # (MCU_SEL_V << MCU_SEL_S)
var MCU_SEL_V* {.importc: "MCU_SEL_V", header: "io_mux_reg.h".}: int  # 0x7
var MCU_SEL_S* {.importc: "MCU_SEL_S", header: "io_mux_reg.h".}: int  # 12

#define PIN_INPUT_ENABLE(PIN_NAME)               SET_PERI_REG_MASK(PIN_NAME,FUN_IE)
#define PIN_INPUT_DISABLE(PIN_NAME)              CLEAR_PERI_REG_MASK(PIN_NAME,FUN_IE)
#define PIN_SET_DRV(PIN_NAME, drv)            REG_SET_FIELD(PIN_NAME, FUN_DRV, (drv));

#define PIN_FUNC_SELECT(PIN_NAME, FUNC)      REG_SET_FIELD(PIN_NAME, MCU_SEL, FUNC)

var PIN_FUNC_GPIO* {.importc: "PIN_FUNC_GPIO", header: "io_mux_reg.h".}: int  #                               2

var PIN_CTRL* {.importc: "PIN_CTRL", header: "io_mux_reg.h".}: int  #                          (DR_REG_IO_MUX_BASE +0x00)
var CLK_OUT3* {.importc: "CLK_OUT3", header: "io_mux_reg.h".}: int  #                                    0xf
var CLK_OUT3_V* {.importc: "CLK_OUT3_V", header: "io_mux_reg.h".}: int  #                                  CLK_OUT3
var CLK_OUT3_S* {.importc: "CLK_OUT3_S", header: "io_mux_reg.h".}: int  #                                  8
var CLK_OUT3_M* {.importc: "CLK_OUT3_M", header: "io_mux_reg.h".}: int  #                                  (CLK_OUT3_V << CLK_OUT3_S)
var CLK_OUT2* {.importc: "CLK_OUT2", header: "io_mux_reg.h".}: int  #                                    0xf
var CLK_OUT2_V* {.importc: "CLK_OUT2_V", header: "io_mux_reg.h".}: int  #                                  CLK_OUT2
var CLK_OUT2_S* {.importc: "CLK_OUT2_S", header: "io_mux_reg.h".}: int  #                                  4
var CLK_OUT2_M* {.importc: "CLK_OUT2_M", header: "io_mux_reg.h".}: int  #                                  (CLK_OUT2_V << CLK_OUT2_S)
var CLK_OUT1* {.importc: "CLK_OUT1", header: "io_mux_reg.h".}: int  #                                    0xf
var CLK_OUT1_V* {.importc: "CLK_OUT1_V", header: "io_mux_reg.h".}: int  #                                  CLK_OUT1
var CLK_OUT1_S* {.importc: "CLK_OUT1_S", header: "io_mux_reg.h".}: int  #                                  0
var CLK_OUT1_M* {.importc: "CLK_OUT1_M", header: "io_mux_reg.h".}: int  #                                  (CLK_OUT1_V << CLK_OUT1_S)

var PERIPHS_IO_MUX_GPIO0_U* {.importc: "PERIPHS_IO_MUX_GPIO0_U", header: "io_mux_reg.h".}: int  #            (DR_REG_IO_MUX_BASE +0x44)
var IO_MUX_GPIO0_REG* {.importc: "IO_MUX_GPIO0_REG", header: "io_mux_reg.h".}: int  #                  PERIPHS_IO_MUX_GPIO0_U
var FUNC_GPIO0_EMAC_TX_CLK* {.importc: "FUNC_GPIO0_EMAC_TX_CLK", header: "io_mux_reg.h".}: int  #                      5
var FUNC_GPIO0_GPIO0* {.importc: "FUNC_GPIO0_GPIO0", header: "io_mux_reg.h".}: int  #                            2
var FUNC_GPIO0_CLK_OUT1* {.importc: "FUNC_GPIO0_CLK_OUT1", header: "io_mux_reg.h".}: int  #                         1
var FUNC_GPIO0_GPIO0_0* {.importc: "FUNC_GPIO0_GPIO0_0", header: "io_mux_reg.h".}: int  #                          0

var PERIPHS_IO_MUX_U0TXD_U* {.importc: "PERIPHS_IO_MUX_U0TXD_U", header: "io_mux_reg.h".}: int  #            (DR_REG_IO_MUX_BASE +0x88)
var IO_MUX_GPIO1_REG* {.importc: "IO_MUX_GPIO1_REG", header: "io_mux_reg.h".}: int  #                  PERIPHS_IO_MUX_U0TXD_U
var FUNC_U0TXD_EMAC_RXD2* {.importc: "FUNC_U0TXD_EMAC_RXD2", header: "io_mux_reg.h".}: int  #                        5
var FUNC_U0TXD_GPIO1* {.importc: "FUNC_U0TXD_GPIO1", header: "io_mux_reg.h".}: int  #                            2
var FUNC_U0TXD_CLK_OUT3* {.importc: "FUNC_U0TXD_CLK_OUT3", header: "io_mux_reg.h".}: int  #                         1
var FUNC_U0TXD_U0TXD* {.importc: "FUNC_U0TXD_U0TXD", header: "io_mux_reg.h".}: int  #                            0

var PERIPHS_IO_MUX_GPIO2_U* {.importc: "PERIPHS_IO_MUX_GPIO2_U", header: "io_mux_reg.h".}: int  #            (DR_REG_IO_MUX_BASE +0x40)
var IO_MUX_GPIO2_REG* {.importc: "IO_MUX_GPIO2_REG", header: "io_mux_reg.h".}: int  #                  PERIPHS_IO_MUX_GPIO2_U
var FUNC_GPIO2_SD_DATA0* {.importc: "FUNC_GPIO2_SD_DATA0", header: "io_mux_reg.h".}: int  #                         4
var FUNC_GPIO2_HS2_DATA0* {.importc: "FUNC_GPIO2_HS2_DATA0", header: "io_mux_reg.h".}: int  #                        3
var FUNC_GPIO2_GPIO2* {.importc: "FUNC_GPIO2_GPIO2", header: "io_mux_reg.h".}: int  #                            2
var FUNC_GPIO2_HSPIWP* {.importc: "FUNC_GPIO2_HSPIWP", header: "io_mux_reg.h".}: int  #                           1
var FUNC_GPIO2_GPIO2_0* {.importc: "FUNC_GPIO2_GPIO2_0", header: "io_mux_reg.h".}: int  #                          0

var PERIPHS_IO_MUX_U0RXD_U* {.importc: "PERIPHS_IO_MUX_U0RXD_U", header: "io_mux_reg.h".}: int  #            (DR_REG_IO_MUX_BASE +0x84)
var IO_MUX_GPIO3_REG* {.importc: "IO_MUX_GPIO3_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_U0RXD_U
var FUNC_U0RXD_GPIO3* {.importc: "FUNC_U0RXD_GPIO3", header: "io_mux_reg.h".}: int  #                            2
var FUNC_U0RXD_CLK_OUT2* {.importc: "FUNC_U0RXD_CLK_OUT2", header: "io_mux_reg.h".}: int  #                         1
var FUNC_U0RXD_U0RXD* {.importc: "FUNC_U0RXD_U0RXD", header: "io_mux_reg.h".}: int  #                            0

var PERIPHS_IO_MUX_GPIO4_U* {.importc: "PERIPHS_IO_MUX_GPIO4_U", header: "io_mux_reg.h".}: int  #            (DR_REG_IO_MUX_BASE +0x48)
var IO_MUX_GPIO4_REG* {.importc: "IO_MUX_GPIO4_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO4_U
var FUNC_GPIO4_EMAC_TX_ER* {.importc: "FUNC_GPIO4_EMAC_TX_ER", header: "io_mux_reg.h".}: int  #                       5
var FUNC_GPIO4_SD_DATA1* {.importc: "FUNC_GPIO4_SD_DATA1", header: "io_mux_reg.h".}: int  #                         4
var FUNC_GPIO4_HS2_DATA1* {.importc: "FUNC_GPIO4_HS2_DATA1", header: "io_mux_reg.h".}: int  #                        3
var FUNC_GPIO4_GPIO4* {.importc: "FUNC_GPIO4_GPIO4", header: "io_mux_reg.h".}: int  #                            2
var FUNC_GPIO4_HSPIHD* {.importc: "FUNC_GPIO4_HSPIHD", header: "io_mux_reg.h".}: int  #                           1
var FUNC_GPIO4_GPIO4_0* {.importc: "FUNC_GPIO4_GPIO4_0", header: "io_mux_reg.h".}: int  #                          0

var PERIPHS_IO_MUX_GPIO5_U* {.importc: "PERIPHS_IO_MUX_GPIO5_U", header: "io_mux_reg.h".}: int  #            (DR_REG_IO_MUX_BASE +0x6c)
var IO_MUX_GPIO5_REG* {.importc: "IO_MUX_GPIO5_REG", header: "io_mux_reg.h".}: int  #                   PERIPHS_IO_MUX_GPIO5_U
var FUNC_GPIO5_EMAC_RX_CLK* {.importc: "FUNC_GPIO5_EMAC_RX_CLK", header: "io_mux_reg.h".}: int  #                      5
var FUNC_GPIO5_HS1_DATA6* {.importc: "FUNC_GPIO5_HS1_DATA6", header: "io_mux_reg.h".}: int  #                        3
var FUNC_GPIO5_GPIO5* {.importc: "FUNC_GPIO5_GPIO5", header: "io_mux_reg.h".}: int  #                            2
var FUNC_GPIO5_VSPICS0* {.importc: "FUNC_GPIO5_VSPICS0", header: "io_mux_reg.h".}: int  #                          1
var FUNC_GPIO5_GPIO5_0* {.importc: "FUNC_GPIO5_GPIO5_0", header: "io_mux_reg.h".}: int  #                          0

var PERIPHS_IO_MUX_SD_CLK_U* {.importc: "PERIPHS_IO_MUX_SD_CLK_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x60)
var IO_MUX_GPIO6_REG* {.importc: "IO_MUX_GPIO6_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_SD_CLK_U
var FUNC_SD_CLK_U1CTS* {.importc: "FUNC_SD_CLK_U1CTS", header: "io_mux_reg.h".}: int  #                           4
var FUNC_SD_CLK_HS1_CLK* {.importc: "FUNC_SD_CLK_HS1_CLK", header: "io_mux_reg.h".}: int  #                         3
var FUNC_SD_CLK_GPIO6* {.importc: "FUNC_SD_CLK_GPIO6", header: "io_mux_reg.h".}: int  #                           2
var FUNC_SD_CLK_SPICLK* {.importc: "FUNC_SD_CLK_SPICLK", header: "io_mux_reg.h".}: int  #                          1
var FUNC_SD_CLK_SD_CLK* {.importc: "FUNC_SD_CLK_SD_CLK", header: "io_mux_reg.h".}: int  #                          0

var PERIPHS_IO_MUX_SD_DATA0_U* {.importc: "PERIPHS_IO_MUX_SD_DATA0_U", header: "io_mux_reg.h".}: int  #         (DR_REG_IO_MUX_BASE +0x64)
var IO_MUX_GPIO7_REG* {.importc: "IO_MUX_GPIO7_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_SD_DATA0_U
var FUNC_SD_DATA0_U2RTS* {.importc: "FUNC_SD_DATA0_U2RTS", header: "io_mux_reg.h".}: int  #                         4
var FUNC_SD_DATA0_HS1_DATA0* {.importc: "FUNC_SD_DATA0_HS1_DATA0", header: "io_mux_reg.h".}: int  #                     3
var FUNC_SD_DATA0_GPIO7* {.importc: "FUNC_SD_DATA0_GPIO7", header: "io_mux_reg.h".}: int  #                         2
var FUNC_SD_DATA0_SPIQ* {.importc: "FUNC_SD_DATA0_SPIQ", header: "io_mux_reg.h".}: int  #                          1
var FUNC_SD_DATA0_SD_DATA0* {.importc: "FUNC_SD_DATA0_SD_DATA0", header: "io_mux_reg.h".}: int  #                      0

var PERIPHS_IO_MUX_SD_DATA1_U* {.importc: "PERIPHS_IO_MUX_SD_DATA1_U", header: "io_mux_reg.h".}: int  #         (DR_REG_IO_MUX_BASE +0x68)
var IO_MUX_GPIO8_REG* {.importc: "IO_MUX_GPIO8_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_SD_DATA1_U
var FUNC_SD_DATA1_U2CTS* {.importc: "FUNC_SD_DATA1_U2CTS", header: "io_mux_reg.h".}: int  #                         4
var FUNC_SD_DATA1_HS1_DATA1* {.importc: "FUNC_SD_DATA1_HS1_DATA1", header: "io_mux_reg.h".}: int  #                     3
var FUNC_SD_DATA1_GPIO8* {.importc: "FUNC_SD_DATA1_GPIO8", header: "io_mux_reg.h".}: int  #                         2
var FUNC_SD_DATA1_SPID* {.importc: "FUNC_SD_DATA1_SPID", header: "io_mux_reg.h".}: int  #                          1
var FUNC_SD_DATA1_SD_DATA1* {.importc: "FUNC_SD_DATA1_SD_DATA1", header: "io_mux_reg.h".}: int  #                      0

var PERIPHS_IO_MUX_SD_DATA2_U* {.importc: "PERIPHS_IO_MUX_SD_DATA2_U", header: "io_mux_reg.h".}: int  #         (DR_REG_IO_MUX_BASE +0x54)
var IO_MUX_GPIO9_REG* {.importc: "IO_MUX_GPIO9_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_SD_DATA2_U
var FUNC_SD_DATA2_U1RXD* {.importc: "FUNC_SD_DATA2_U1RXD", header: "io_mux_reg.h".}: int  #                         4
var FUNC_SD_DATA2_HS1_DATA2* {.importc: "FUNC_SD_DATA2_HS1_DATA2", header: "io_mux_reg.h".}: int  #                     3
var FUNC_SD_DATA2_GPIO9* {.importc: "FUNC_SD_DATA2_GPIO9", header: "io_mux_reg.h".}: int  #                         2
var FUNC_SD_DATA2_SPIHD* {.importc: "FUNC_SD_DATA2_SPIHD", header: "io_mux_reg.h".}: int  #                         1
var FUNC_SD_DATA2_SD_DATA2* {.importc: "FUNC_SD_DATA2_SD_DATA2", header: "io_mux_reg.h".}: int  #                      0

var PERIPHS_IO_MUX_SD_DATA3_U* {.importc: "PERIPHS_IO_MUX_SD_DATA3_U", header: "io_mux_reg.h".}: int  #         (DR_REG_IO_MUX_BASE +0x58)
var IO_MUX_GPIO10_REG* {.importc: "IO_MUX_GPIO10_REG", header: "io_mux_reg.h".}: int  #                   PERIPHS_IO_MUX_SD_DATA3_U
var FUNC_SD_DATA3_U1TXD* {.importc: "FUNC_SD_DATA3_U1TXD", header: "io_mux_reg.h".}: int  #                         4
var FUNC_SD_DATA3_HS1_DATA3* {.importc: "FUNC_SD_DATA3_HS1_DATA3", header: "io_mux_reg.h".}: int  #                     3
var FUNC_SD_DATA3_GPIO10* {.importc: "FUNC_SD_DATA3_GPIO10", header: "io_mux_reg.h".}: int  #                        2
var FUNC_SD_DATA3_SPIWP* {.importc: "FUNC_SD_DATA3_SPIWP", header: "io_mux_reg.h".}: int  #                         1
var FUNC_SD_DATA3_SD_DATA3* {.importc: "FUNC_SD_DATA3_SD_DATA3", header: "io_mux_reg.h".}: int  #                      0

var PERIPHS_IO_MUX_SD_CMD_U* {.importc: "PERIPHS_IO_MUX_SD_CMD_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x5c)
var IO_MUX_GPIO11_REG* {.importc: "IO_MUX_GPIO11_REG", header: "io_mux_reg.h".}: int  #                   PERIPHS_IO_MUX_SD_CMD_U
var FUNC_SD_CMD_U1RTS* {.importc: "FUNC_SD_CMD_U1RTS", header: "io_mux_reg.h".}: int  #                           4
var FUNC_SD_CMD_HS1_CMD* {.importc: "FUNC_SD_CMD_HS1_CMD", header: "io_mux_reg.h".}: int  #                         3
var FUNC_SD_CMD_GPIO11* {.importc: "FUNC_SD_CMD_GPIO11", header: "io_mux_reg.h".}: int  #                          2
var FUNC_SD_CMD_SPICS0* {.importc: "FUNC_SD_CMD_SPICS0", header: "io_mux_reg.h".}: int  #                          1
var FUNC_SD_CMD_SD_CMD* {.importc: "FUNC_SD_CMD_SD_CMD", header: "io_mux_reg.h".}: int  #                          0

var PERIPHS_IO_MUX_MTDI_U* {.importc: "PERIPHS_IO_MUX_MTDI_U", header: "io_mux_reg.h".}: int  #             (DR_REG_IO_MUX_BASE +0x34)
var IO_MUX_GPIO12_REG* {.importc: "IO_MUX_GPIO12_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_MTDI_U
var FUNC_MTDI_EMAC_TXD3* {.importc: "FUNC_MTDI_EMAC_TXD3", header: "io_mux_reg.h".}: int  #                         5
var FUNC_MTDI_SD_DATA2* {.importc: "FUNC_MTDI_SD_DATA2", header: "io_mux_reg.h".}: int  #                          4
var FUNC_MTDI_HS2_DATA2* {.importc: "FUNC_MTDI_HS2_DATA2", header: "io_mux_reg.h".}: int  #                         3
var FUNC_MTDI_GPIO12* {.importc: "FUNC_MTDI_GPIO12", header: "io_mux_reg.h".}: int  #                            2
var FUNC_MTDI_HSPIQ* {.importc: "FUNC_MTDI_HSPIQ", header: "io_mux_reg.h".}: int  #                             1
var FUNC_MTDI_MTDI* {.importc: "FUNC_MTDI_MTDI", header: "io_mux_reg.h".}: int  #                              0

var PERIPHS_IO_MUX_MTCK_U* {.importc: "PERIPHS_IO_MUX_MTCK_U", header: "io_mux_reg.h".}: int  #             (DR_REG_IO_MUX_BASE +0x38)
var IO_MUX_GPIO13_REG* {.importc: "IO_MUX_GPIO13_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_MTCK_U
var FUNC_MTCK_EMAC_RX_ER* {.importc: "FUNC_MTCK_EMAC_RX_ER", header: "io_mux_reg.h".}: int  #                        5
var FUNC_MTCK_SD_DATA3* {.importc: "FUNC_MTCK_SD_DATA3", header: "io_mux_reg.h".}: int  #                          4
var FUNC_MTCK_HS2_DATA3* {.importc: "FUNC_MTCK_HS2_DATA3", header: "io_mux_reg.h".}: int  #                         3
var FUNC_MTCK_GPIO13* {.importc: "FUNC_MTCK_GPIO13", header: "io_mux_reg.h".}: int  #                            2
var FUNC_MTCK_HSPID* {.importc: "FUNC_MTCK_HSPID", header: "io_mux_reg.h".}: int  #                             1
var FUNC_MTCK_MTCK* {.importc: "FUNC_MTCK_MTCK", header: "io_mux_reg.h".}: int  #                              0

var PERIPHS_IO_MUX_MTMS_U* {.importc: "PERIPHS_IO_MUX_MTMS_U", header: "io_mux_reg.h".}: int  #             (DR_REG_IO_MUX_BASE +0x30)
var IO_MUX_GPIO14_REG* {.importc: "IO_MUX_GPIO14_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_MTMS_U
var FUNC_MTMS_EMAC_TXD2* {.importc: "FUNC_MTMS_EMAC_TXD2", header: "io_mux_reg.h".}: int  #                         5
var FUNC_MTMS_SD_CLK* {.importc: "FUNC_MTMS_SD_CLK", header: "io_mux_reg.h".}: int  #                            4
var FUNC_MTMS_HS2_CLK* {.importc: "FUNC_MTMS_HS2_CLK", header: "io_mux_reg.h".}: int  #                           3
var FUNC_MTMS_GPIO14* {.importc: "FUNC_MTMS_GPIO14", header: "io_mux_reg.h".}: int  #                            2
var FUNC_MTMS_HSPICLK* {.importc: "FUNC_MTMS_HSPICLK", header: "io_mux_reg.h".}: int  #                           1
var FUNC_MTMS_MTMS* {.importc: "FUNC_MTMS_MTMS", header: "io_mux_reg.h".}: int  #                              0

var PERIPHS_IO_MUX_MTDO_U* {.importc: "PERIPHS_IO_MUX_MTDO_U", header: "io_mux_reg.h".}: int  #             (DR_REG_IO_MUX_BASE +0x3c)
var IO_MUX_GPIO15_REG* {.importc: "IO_MUX_GPIO15_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_MTDO_U
var FUNC_MTDO_EMAC_RXD3* {.importc: "FUNC_MTDO_EMAC_RXD3", header: "io_mux_reg.h".}: int  #                         5
var FUNC_MTDO_SD_CMD* {.importc: "FUNC_MTDO_SD_CMD", header: "io_mux_reg.h".}: int  #                            4
var FUNC_MTDO_HS2_CMD* {.importc: "FUNC_MTDO_HS2_CMD", header: "io_mux_reg.h".}: int  #                           3
var FUNC_MTDO_GPIO15* {.importc: "FUNC_MTDO_GPIO15", header: "io_mux_reg.h".}: int  #                            2
var FUNC_MTDO_HSPICS0* {.importc: "FUNC_MTDO_HSPICS0", header: "io_mux_reg.h".}: int  #                           1
var FUNC_MTDO_MTDO* {.importc: "FUNC_MTDO_MTDO", header: "io_mux_reg.h".}: int  #                              0

var PERIPHS_IO_MUX_GPIO16_U* {.importc: "PERIPHS_IO_MUX_GPIO16_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x4c)
var IO_MUX_GPIO16_REG* {.importc: "IO_MUX_GPIO16_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO16_U
var FUNC_GPIO16_EMAC_CLK_OUT* {.importc: "FUNC_GPIO16_EMAC_CLK_OUT", header: "io_mux_reg.h".}: int  #                    5
var FUNC_GPIO16_U2RXD* {.importc: "FUNC_GPIO16_U2RXD", header: "io_mux_reg.h".}: int  #                           4
var FUNC_GPIO16_HS1_DATA4* {.importc: "FUNC_GPIO16_HS1_DATA4", header: "io_mux_reg.h".}: int  #                       3
var FUNC_GPIO16_GPIO16* {.importc: "FUNC_GPIO16_GPIO16", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO16_GPIO16_0* {.importc: "FUNC_GPIO16_GPIO16_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO17_U* {.importc: "PERIPHS_IO_MUX_GPIO17_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x50)
var IO_MUX_GPIO17_REG* {.importc: "IO_MUX_GPIO17_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO17_U
var FUNC_GPIO17_EMAC_CLK_OUT_180* {.importc: "FUNC_GPIO17_EMAC_CLK_OUT_180", header: "io_mux_reg.h".}: int  #                5
var FUNC_GPIO17_U2TXD* {.importc: "FUNC_GPIO17_U2TXD", header: "io_mux_reg.h".}: int  #                           4
var FUNC_GPIO17_HS1_DATA5* {.importc: "FUNC_GPIO17_HS1_DATA5", header: "io_mux_reg.h".}: int  #                       3
var FUNC_GPIO17_GPIO17* {.importc: "FUNC_GPIO17_GPIO17", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO17_GPIO17_0* {.importc: "FUNC_GPIO17_GPIO17_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO18_U* {.importc: "PERIPHS_IO_MUX_GPIO18_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x70)
var IO_MUX_GPIO18_REG* {.importc: "IO_MUX_GPIO18_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO18_U
var FUNC_GPIO18_HS1_DATA7* {.importc: "FUNC_GPIO18_HS1_DATA7", header: "io_mux_reg.h".}: int  #                       3
var FUNC_GPIO18_GPIO18* {.importc: "FUNC_GPIO18_GPIO18", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO18_VSPICLK* {.importc: "FUNC_GPIO18_VSPICLK", header: "io_mux_reg.h".}: int  #                         1
var FUNC_GPIO18_GPIO18_0* {.importc: "FUNC_GPIO18_GPIO18_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO19_U* {.importc: "PERIPHS_IO_MUX_GPIO19_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x74)
var IO_MUX_GPIO19_REG* {.importc: "IO_MUX_GPIO19_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO19_U
var FUNC_GPIO19_EMAC_TXD0* {.importc: "FUNC_GPIO19_EMAC_TXD0", header: "io_mux_reg.h".}: int  #                       5
var FUNC_GPIO19_U0CTS* {.importc: "FUNC_GPIO19_U0CTS", header: "io_mux_reg.h".}: int  #                           3
var FUNC_GPIO19_GPIO19* {.importc: "FUNC_GPIO19_GPIO19", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO19_VSPIQ* {.importc: "FUNC_GPIO19_VSPIQ", header: "io_mux_reg.h".}: int  #                           1
var FUNC_GPIO19_GPIO19_0* {.importc: "FUNC_GPIO19_GPIO19_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO20_U* {.importc: "PERIPHS_IO_MUX_GPIO20_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x78)
var IO_MUX_GPIO20_REG* {.importc: "IO_MUX_GPIO20_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO20_U
var FUNC_GPIO20_GPIO20* {.importc: "FUNC_GPIO20_GPIO20", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO20_GPIO20_0* {.importc: "FUNC_GPIO20_GPIO20_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO21_U* {.importc: "PERIPHS_IO_MUX_GPIO21_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x7c)
var IO_MUX_GPIO21_REG* {.importc: "IO_MUX_GPIO21_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO21_U
var FUNC_GPIO21_EMAC_TX_EN* {.importc: "FUNC_GPIO21_EMAC_TX_EN", header: "io_mux_reg.h".}: int  #                      5
var FUNC_GPIO21_GPIO21* {.importc: "FUNC_GPIO21_GPIO21", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO21_VSPIHD* {.importc: "FUNC_GPIO21_VSPIHD", header: "io_mux_reg.h".}: int  #                          1
var FUNC_GPIO21_GPIO21_0* {.importc: "FUNC_GPIO21_GPIO21_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO22_U* {.importc: "PERIPHS_IO_MUX_GPIO22_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x80)
var IO_MUX_GPIO22_REG* {.importc: "IO_MUX_GPIO22_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO22_U
var FUNC_GPIO22_EMAC_TXD1* {.importc: "FUNC_GPIO22_EMAC_TXD1", header: "io_mux_reg.h".}: int  #                       5
var FUNC_GPIO22_U0RTS* {.importc: "FUNC_GPIO22_U0RTS", header: "io_mux_reg.h".}: int  #                           3
var FUNC_GPIO22_GPIO22* {.importc: "FUNC_GPIO22_GPIO22", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO22_VSPIWP* {.importc: "FUNC_GPIO22_VSPIWP", header: "io_mux_reg.h".}: int  #                          1
var FUNC_GPIO22_GPIO22_0* {.importc: "FUNC_GPIO22_GPIO22_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO23_U* {.importc: "PERIPHS_IO_MUX_GPIO23_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x8c)
var IO_MUX_GPIO23_REG* {.importc: "IO_MUX_GPIO23_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO23_U
var FUNC_GPIO23_HS1_STROBE* {.importc: "FUNC_GPIO23_HS1_STROBE", header: "io_mux_reg.h".}: int  #                      3
var FUNC_GPIO23_GPIO23* {.importc: "FUNC_GPIO23_GPIO23", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO23_VSPID* {.importc: "FUNC_GPIO23_VSPID", header: "io_mux_reg.h".}: int  #                           1
var FUNC_GPIO23_GPIO23_0* {.importc: "FUNC_GPIO23_GPIO23_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO24_U* {.importc: "PERIPHS_IO_MUX_GPIO24_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x90)
var IO_MUX_GPIO24_REG* {.importc: "IO_MUX_GPIO24_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO24_U
var FUNC_GPIO24_GPIO24* {.importc: "FUNC_GPIO24_GPIO24", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO24_GPIO24_0* {.importc: "FUNC_GPIO24_GPIO24_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO25_U* {.importc: "PERIPHS_IO_MUX_GPIO25_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x24)
var IO_MUX_GPIO25_REG* {.importc: "IO_MUX_GPIO25_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO25_U
var FUNC_GPIO25_EMAC_RXD0* {.importc: "FUNC_GPIO25_EMAC_RXD0", header: "io_mux_reg.h".}: int  #                       5
var FUNC_GPIO25_GPIO25* {.importc: "FUNC_GPIO25_GPIO25", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO25_GPIO25_0* {.importc: "FUNC_GPIO25_GPIO25_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO26_U* {.importc: "PERIPHS_IO_MUX_GPIO26_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x28)
var IO_MUX_GPIO26_REG* {.importc: "IO_MUX_GPIO26_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO26_U
var FUNC_GPIO26_EMAC_RXD1* {.importc: "FUNC_GPIO26_EMAC_RXD1", header: "io_mux_reg.h".}: int  #                       5
var FUNC_GPIO26_GPIO26* {.importc: "FUNC_GPIO26_GPIO26", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO26_GPIO26_0* {.importc: "FUNC_GPIO26_GPIO26_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO27_U* {.importc: "PERIPHS_IO_MUX_GPIO27_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x2c)
var IO_MUX_GPIO27_REG* {.importc: "IO_MUX_GPIO27_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO27_U
var FUNC_GPIO27_EMAC_RX_DV* {.importc: "FUNC_GPIO27_EMAC_RX_DV", header: "io_mux_reg.h".}: int  #                      5
var FUNC_GPIO27_GPIO27* {.importc: "FUNC_GPIO27_GPIO27", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO27_GPIO27_0* {.importc: "FUNC_GPIO27_GPIO27_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO32_U* {.importc: "PERIPHS_IO_MUX_GPIO32_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x1c)
var IO_MUX_GPIO32_REG* {.importc: "IO_MUX_GPIO32_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO32_U
var FUNC_GPIO32_GPIO32* {.importc: "FUNC_GPIO32_GPIO32", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO32_GPIO32_0* {.importc: "FUNC_GPIO32_GPIO32_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO33_U* {.importc: "PERIPHS_IO_MUX_GPIO33_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x20)
var IO_MUX_GPIO33_REG* {.importc: "IO_MUX_GPIO33_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO33_U
var FUNC_GPIO33_GPIO33* {.importc: "FUNC_GPIO33_GPIO33", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO33_GPIO33_0* {.importc: "FUNC_GPIO33_GPIO33_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO34_U* {.importc: "PERIPHS_IO_MUX_GPIO34_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x14)
var IO_MUX_GPIO34_REG* {.importc: "IO_MUX_GPIO34_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO34_U
var FUNC_GPIO34_GPIO34* {.importc: "FUNC_GPIO34_GPIO34", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO34_GPIO34_0* {.importc: "FUNC_GPIO34_GPIO34_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO35_U* {.importc: "PERIPHS_IO_MUX_GPIO35_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x18)
var IO_MUX_GPIO35_REG* {.importc: "IO_MUX_GPIO35_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO35_U
var FUNC_GPIO35_GPIO35* {.importc: "FUNC_GPIO35_GPIO35", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO35_GPIO35_0* {.importc: "FUNC_GPIO35_GPIO35_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO36_U* {.importc: "PERIPHS_IO_MUX_GPIO36_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x04)
var IO_MUX_GPIO36_REG* {.importc: "IO_MUX_GPIO36_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO36_U
var FUNC_GPIO36_GPIO36* {.importc: "FUNC_GPIO36_GPIO36", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO36_GPIO36_0* {.importc: "FUNC_GPIO36_GPIO36_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO37_U* {.importc: "PERIPHS_IO_MUX_GPIO37_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x08)
var IO_MUX_GPIO37_REG* {.importc: "IO_MUX_GPIO37_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO37_U
var FUNC_GPIO37_GPIO37* {.importc: "FUNC_GPIO37_GPIO37", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO37_GPIO37_0* {.importc: "FUNC_GPIO37_GPIO37_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO38_U* {.importc: "PERIPHS_IO_MUX_GPIO38_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x0c)
var IO_MUX_GPIO38_REG* {.importc: "IO_MUX_GPIO38_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO38_U
var FUNC_GPIO38_GPIO38* {.importc: "FUNC_GPIO38_GPIO38", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO38_GPIO38_0* {.importc: "FUNC_GPIO38_GPIO38_0", header: "io_mux_reg.h".}: int  #                        0

var PERIPHS_IO_MUX_GPIO39_U* {.importc: "PERIPHS_IO_MUX_GPIO39_U", header: "io_mux_reg.h".}: int  #           (DR_REG_IO_MUX_BASE +0x10)
var IO_MUX_GPIO39_REG* {.importc: "IO_MUX_GPIO39_REG", header: "io_mux_reg.h".}: int  #                    PERIPHS_IO_MUX_GPIO39_U
var FUNC_GPIO39_GPIO39* {.importc: "FUNC_GPIO39_GPIO39", header: "io_mux_reg.h".}: int  #                          2
var FUNC_GPIO39_GPIO39_0* {.importc: "FUNC_GPIO39_GPIO39_0", header: "io_mux_reg.h".}: int  #                        0

#endif #  _SOC_IO_MUX_REG_H_ 

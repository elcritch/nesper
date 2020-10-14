##  Copyright 2015-2018 Espressif Systems (Shanghai) PTE LTD
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

import
  soc/periph_defs

## *
##  @brief      enable peripheral module
##
##  @param[in]  periph    :  Peripheral module name
##
##  Clock for the module will be ungated, and reset de-asserted.
##
##  @return     NULL
##
##

proc periph_module_enable*(periph: periph_module_t) {.
    importc: "periph_module_enable", header: "periph_ctrl.h".}
## *
##  @brief      disable peripheral module
##
##  @param[in]  periph    :  Peripheral module name
##
##  Clock for the module will be gated, reset asserted.
##
##  @return     NULL
##
##

proc periph_module_disable*(periph: periph_module_t) {.
    importc: "periph_module_disable", header: "periph_ctrl.h".}
## *
##  @brief      reset peripheral module
##
##  @param[in]  periph    :  Peripheral module name
##
##  Reset will asserted then de-assrted for the peripheral.
##
##  Calling this function does not enable or disable the clock for the module.
##
##  @return     NULL
##
##

proc periph_module_reset*(periph: periph_module_t) {.
    importc: "periph_module_reset", header: "periph_ctrl.h".}
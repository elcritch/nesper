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
##  Internal header, don't use it in the user code

import
  driver/spi_common

## *
##  @brief Try to claim a SPI peripheral
##
##  Call this if your driver wants to manage a SPI peripheral.
##
##  @param host Peripheral to claim
##  @param source The caller indentification string.
##
##  @note This public API is deprecated.
##
##  @return True if peripheral is claimed successfully; false if peripheral already is claimed.
##

proc spicommon_periph_claim*(host: spi_host_device_t; source: cstring): bool {.
    importc: "spicommon_periph_claim", header: "spi_common_internal.h".}
## *
##  @brief Check whether the spi periph is in use.
##
##  @param host Peripheral to check.
##
##  @note This public API is deprecated.
##
##  @return True if in use, otherwise false.
##

proc spicommon_periph_in_use*(host: spi_host_device_t): bool {.
    importc: "spicommon_periph_in_use", header: "spi_common_internal.h".}
## *
##  @brief Return the SPI peripheral so another driver can claim it.
##
##  @param host Peripheral to return
##
##  @note This public API is deprecated.
##
##  @return True if peripheral is returned successfully; false if peripheral was free to claim already.
##

proc spicommon_periph_free*(host: spi_host_device_t): bool {.
    importc: "spicommon_periph_free", header: "spi_common_internal.h".}
## *
##  @brief Try to claim a SPI DMA channel
##
##   Call this if your driver wants to use SPI with a DMA channnel.
##
##  @param dma_chan channel to claim
##
##  @note This public API is deprecated.
##
##  @return True if success; false otherwise.
##

proc spicommon_dma_chan_claim*(dma_chan: cint): bool {.
    importc: "spicommon_dma_chan_claim", header: "spi_common_internal.h".}
## *
##  @brief Check whether the spi DMA channel is in use.
##
##  @param dma_chan DMA channel to check.
##
##  @note This public API is deprecated.
##
##  @return True if in use, otherwise false.
##

proc spicommon_dma_chan_in_use*(dma_chan: cint): bool {.
    importc: "spicommon_dma_chan_in_use", header: "spi_common_internal.h".}
## *
##  @brief Return the SPI DMA channel so other driver can claim it, or just to power down DMA.
##
##  @param dma_chan channel to return
##
##  @note This public API is deprecated.
##
##  @return True if success; false otherwise.
##

proc spicommon_dma_chan_free*(dma_chan: cint): bool {.
    importc: "spicommon_dma_chan_free", header: "spi_common_internal.h".}
## *
##  @brief Connect a SPI peripheral to GPIO pins
##
##  This routine is used to connect a SPI peripheral to the IO-pads and DMA channel given in
##  the arguments. Depending on the IO-pads requested, the routing is done either using the
##  IO_mux or using the GPIO matrix.
##
##  @note This public API is deprecated. Please call ``spi_bus_initialize`` for master
##        bus initialization and ``spi_slave_initialize`` for slave initialization.
##
##  @param host SPI peripheral to be routed
##  @param bus_config Pointer to a spi_bus_config struct detailing the GPIO pins
##  @param dma_chan DMA-channel (1 or 2) to use, or 0 for no DMA.
##  @param flags Combination of SPICOMMON_BUSFLAG_* flags, set to ensure the pins set are capable with some functions:
##               - ``SPICOMMON_BUSFLAG_MASTER``: Initialize I/O in master mode
##               - ``SPICOMMON_BUSFLAG_SLAVE``: Initialize I/O in slave mode
##               - ``SPICOMMON_BUSFLAG_IOMUX_PINS``: Pins set should match the iomux pins of the controller.
##               - ``SPICOMMON_BUSFLAG_SCLK``, ``SPICOMMON_BUSFLAG_MISO``, ``SPICOMMON_BUSFLAG_MOSI``:
##                   Make sure SCLK/MISO/MOSI is/are set to a valid GPIO. Also check output capability according to the mode.
##               - ``SPICOMMON_BUSFLAG_DUAL``: Make sure both MISO and MOSI are output capable so that DIO mode is capable.
##               - ``SPICOMMON_BUSFLAG_WPHD`` Make sure WP and HD are set to valid output GPIOs.
##               - ``SPICOMMON_BUSFLAG_QUAD``: Combination of ``SPICOMMON_BUSFLAG_DUAL`` and ``SPICOMMON_BUSFLAG_WPHD``.
##  @param[out] flags_o A SPICOMMON_BUSFLAG_* flag combination of bus abilities will be written to this address.
##               Leave to NULL if not needed.
##               - ``SPICOMMON_BUSFLAG_IOMUX_PINS``: The bus is connected to iomux pins.
##               - ``SPICOMMON_BUSFLAG_SCLK``, ``SPICOMMON_BUSFLAG_MISO``, ``SPICOMMON_BUSFLAG_MOSI``: The bus has
##                   CLK/MISO/MOSI connected.
##               - ``SPICOMMON_BUSFLAG_DUAL``: The bus is capable with DIO mode.
##               - ``SPICOMMON_BUSFLAG_WPHD`` The bus has WP and HD connected.
##               - ``SPICOMMON_BUSFLAG_QUAD``: Combination of ``SPICOMMON_BUSFLAG_DUAL`` and ``SPICOMMON_BUSFLAG_WPHD``.
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_OK                on success
##

proc spicommon_bus_initialize_io*(host: spi_host_device_t;
                                 bus_config: ptr spi_bus_config_t; dma_chan: cint;
                                 flags: uint32; flags_o: ptr uint32): esp_err_t {.
    importc: "spicommon_bus_initialize_io", header: "spi_common_internal.h".}
## *
##  @brief Free the IO used by a SPI peripheral
##
##  @note This public API is deprecated. Please call ``spi_bus_free`` for master
##        bus deinitialization and ``spi_slave_free`` for slave deinitialization.
##
##  @param bus_cfg Bus config struct which defines which pins to be used.
##
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_OK                on success
##

proc spicommon_bus_free_io_cfg*(bus_cfg: ptr spi_bus_config_t): esp_err_t {.
    importc: "spicommon_bus_free_io_cfg", header: "spi_common_internal.h".}
## *
##  @brief Initialize a Chip Select pin for a specific SPI peripheral
##
##  @note This public API is deprecated. Please call corresponding device initialization
##        functions.
##
##  @param host SPI peripheral
##  @param cs_io_num GPIO pin to route
##  @param cs_num CS id to route
##  @param force_gpio_matrix If true, CS will always be routed through the GPIO matrix. If false,
##                           if the GPIO number allows it, the routing will happen through the IO_mux.
##

proc spicommon_cs_initialize*(host: spi_host_device_t; cs_io_num: cint; cs_num: cint;
                             force_gpio_matrix: cint) {.
    importc: "spicommon_cs_initialize", header: "spi_common_internal.h".}
## *
##  @brief Free a chip select line
##
##  @param cs_gpio_num CS gpio num to free
##
##  @note This public API is deprecated.
##

proc spicommon_cs_free_io*(cs_gpio_num: cint) {.importc: "spicommon_cs_free_io",
    header: "spi_common_internal.h".}
## *
##  @brief Check whether all pins used by a host are through IOMUX.
##
##  @param host SPI peripheral
##
##  @note This public API is deprecated.
##
##  @return false if any pins are through the GPIO matrix, otherwise true.
##

proc spicommon_bus_using_iomux*(host: spi_host_device_t): bool {.
    importc: "spicommon_bus_using_iomux", header: "spi_common_internal.h".}
## *
##  @brief Get the IRQ source for a specific SPI host
##
##  @param host The SPI host
##
##  @note This public API is deprecated.
##
##  @return The hosts IRQ source
##

proc spicommon_irqsource_for_host*(host: spi_host_device_t): cint {.
    importc: "spicommon_irqsource_for_host", header: "spi_common_internal.h".}
## *
##  @brief Get the IRQ source for a specific SPI DMA
##
##  @param host The SPI host
##
##  @note This public API is deprecated.
##
##  @return The hosts IRQ source
##

proc spicommon_irqdma_source_for_host*(host: spi_host_device_t): cint {.
    importc: "spicommon_irqdma_source_for_host", header: "spi_common_internal.h".}
## *
##  Callback, to be called when a DMA engine reset is completed
##

type
  dmaworkaround_cb_t* = proc (arg: pointer)

## *
##  @brief Request a reset for a certain DMA channel
##
##  @note In some (well-defined) cases in the ESP32 (at least rev v.0 and v.1), a SPI DMA channel will get confused. This can be remedied
##  by resetting the SPI DMA hardware in case this happens. Unfortunately, the reset knob used for thsi will reset _both_ DMA channels, and
##  as such can only done safely when both DMA channels are idle. These functions coordinate this.
##
##  Essentially, when a reset is needed, a driver can request this using spicommon_dmaworkaround_req_reset. This is supposed to be called
##  with an user-supplied function as an argument. If both DMA channels are idle, this call will reset the DMA subsystem and return true.
##  If the other DMA channel is still busy, it will return false; as soon as the other DMA channel is done, however, it will reset the
##  DMA subsystem and call the callback. The callback is then supposed to be used to continue the SPI drivers activity.
##
##  @param dmachan DMA channel associated with the SPI host that needs a reset
##  @param cb Callback to call in case DMA channel cannot be reset immediately
##  @param arg Argument to the callback
##
##  @note This public API is deprecated.
##
##  @return True when a DMA reset could be executed immediately. False when it could not; in this
##          case the callback will be called with the specified argument when the logic can execute
##          a reset, after that reset.
##

proc spicommon_dmaworkaround_req_reset*(dmachan: cint; cb: dmaworkaround_cb_t;
                                       arg: pointer): bool {.
    importc: "spicommon_dmaworkaround_req_reset", header: "spi_common_internal.h".}
## *
##  @brief Check if a DMA reset is requested but has not completed yet
##
##  @note This public API is deprecated.
##
##  @return True when a DMA reset is requested but hasn't completed yet. False otherwise.
##

proc spicommon_dmaworkaround_reset_in_progress*(): bool {.
    importc: "spicommon_dmaworkaround_reset_in_progress",
    header: "spi_common_internal.h".}
## *
##  @brief Mark a DMA channel as idle.
##
##  A call to this function tells the workaround logic that this channel will
##  not be affected by a global SPI DMA reset.
##
##  @note This public API is deprecated.
##

proc spicommon_dmaworkaround_idle*(dmachan: cint) {.
    importc: "spicommon_dmaworkaround_idle", header: "spi_common_internal.h".}
## *
##  @brief Mark a DMA channel as active.
##
##  A call to this function tells the workaround logic that this channel will
##  be affected by a global SPI DMA reset, and a reset like that should not be attempted.
##
##  @note This public API is deprecated.
##

proc spicommon_dmaworkaround_transfer_active*(dmachan: cint) {.
    importc: "spicommon_dmaworkaround_transfer_active",
    header: "spi_common_internal.h".}
##
##  SPDX-FileCopyrightText: 2019-2023 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

import ../../consts
import ../../net_utils
import ./esp_netif_types

proc esp_netif_attach_wifi_station*(esp_netif: ptr esp_netif_t): esp_err_t {.
    cdecl, importc: "esp_netif_attach_wifi_station",
    header: "esp_wifi_default.h".}
  ##
                                  ##  @brief Attaches wifi station interface to supplied netif
                                  ##
                                  ##  @param esp_netif instance to attach the wifi station to
                                  ##
                                  ##  @return
                                  ##   - ESP_OK on success
                                  ##   - ESP_FAIL if attach failed
                                  ##

proc esp_netif_attach_wifi_ap*(esp_netif: ptr esp_netif_t): esp_err_t {.cdecl,
    importc: "esp_netif_attach_wifi_ap", header: "esp_wifi_default.h".}
  ##
                              ##
                              ##  @brief Attaches wifi soft AP interface to supplied netif
                              ##
                              ##  @param esp_netif instance to attach the wifi AP to
                              ##
                              ##  @return
                              ##   - ESP_OK on success
                              ##   - ESP_FAIL if attach failed
                              ##

proc esp_wifi_set_default_wifi_sta_handlers*(): esp_err_t {.cdecl,
    importc: "esp_wifi_set_default_wifi_sta_handlers",
    header: "esp_wifi_default.h".}
  ##
                                  ##  @brief Sets default wifi event handlers for STA interface
                                  ##
                                  ##  @return
                                  ##   - ESP_OK on success, error returned from esp_event_handler_register if failed
                                  ##

proc esp_wifi_set_default_wifi_ap_handlers*(): esp_err_t {.cdecl,
    importc: "esp_wifi_set_default_wifi_ap_handlers",
    header: "esp_wifi_default.h".}
  ##
                                  ##  @brief Sets default wifi event handlers for AP interface
                                  ##
                                  ##  @return
                                  ##   - ESP_OK on success, error returned from esp_event_handler_register if failed
                                  ##

proc esp_wifi_set_default_wifi_nan_handlers*(): esp_err_t {.cdecl,
    importc: "esp_wifi_set_default_wifi_nan_handlers",
    header: "esp_wifi_default.h".}
  ##
                                  ##  @brief Sets default wifi event handlers for NAN interface
                                  ##
                                  ##  @return
                                  ##   - ESP_OK on success, error returned from esp_event_handler_register if failed
                                  ##

proc esp_wifi_clear_default_wifi_driver_and_handlers*(esp_netif: pointer): esp_err_t {.
    cdecl, importc: "esp_wifi_clear_default_wifi_driver_and_handlers",
    header: "esp_wifi_default.h".}
  ##
                                  ##  @brief Clears default wifi event handlers for supplied network interface
                                  ##
                                  ##  @param esp_netif instance of corresponding if object
                                  ##
                                  ##  @return
                                  ##   - ESP_OK on success, error returned from esp_event_handler_register if failed
                                  ##

proc esp_netif_create_default_wifi_ap*(): ptr esp_netif_t {.cdecl,
    importc: "esp_netif_create_default_wifi_ap", header: "esp_wifi_default.h".}
  ##
                              ##
                              ##  @brief Creates default WIFI AP. In case of any init error this API aborts.
                              ##
                              ##  @note The API creates esp_netif object with default WiFi access point config,
                              ##  attaches the netif to wifi and registers wifi handlers to the default event loop.
                              ##  This API uses assert() to check for potential errors, so it could abort the program.
                              ##  (Note that the default event loop needs to be created prior to calling this API)
                              ##
                              ##  @return pointer to esp-netif instance
                              ##

proc esp_netif_create_default_wifi_sta*(): ptr esp_netif_t {.cdecl,
    importc: "esp_netif_create_default_wifi_sta", header: "esp_wifi_default.h".}
  ##
                              ##
                              ##  @brief Creates default WIFI STA. In case of any init error this API aborts.
                              ##
                              ##  @note The API creates esp_netif object with default WiFi station config,
                              ##  attaches the netif to wifi and registers wifi handlers to the default event loop.
                              ##  This API uses assert() to check for potential errors, so it could abort the program.
                              ##  (Note that the default event loop needs to be created prior to calling this API)
                              ##
                              ##  @return pointer to esp-netif instance
                              ##

proc esp_netif_create_default_wifi_nan*(): ptr esp_netif_t {.cdecl,
    importc: "esp_netif_create_default_wifi_nan", header: "esp_wifi_default.h".}
  ##
                              ##
                              ##  @brief Creates default WIFI NAN. In case of any init error this API aborts.
                              ##
                              ##  @note The API creates esp_netif object with default WiFi station config,
                              ##  attaches the netif to wifi and registers wifi handlers to the default event loop.
                              ##  (Note that the default event loop needs to be created prior to calling this API)
                              ##
                              ##  @return pointer to esp-netif instance
                              ##

proc esp_netif_destroy_default_wifi*(esp_netif: pointer) {.cdecl,
    importc: "esp_netif_destroy_default_wifi", header: "esp_wifi_default.h".}
  ##
                              ##
                              ##  @brief Destroys default WIFI netif created with esp_netif_create_default_wifi_...() API.
                              ##
                              ##  @param[in] esp_netif object to detach from WiFi and destroy
                              ##
                              ##  @note This API unregisters wifi handlers and detaches the created object from the wifi.
                              ##  (this function is a no-operation if esp_netif is NULL)
                              ##

proc esp_netif_create_wifi*(wifi_if: wifi_interface_t;
                            esp_netif_config: ptr esp_netif_inherent_config_t): ptr esp_netif_t {.
    cdecl, importc: "esp_netif_create_wifi", header: "esp_wifi_default.h".}
  ##
                              ##
                              ##  @brief Creates esp_netif WiFi object based on the custom configuration.
                              ##
                              ##  @attention This API DOES NOT register default handlers!
                              ##
                              ##  @param[in] wifi_if type of wifi interface
                              ##  @param[in] esp_netif_config inherent esp-netif configuration pointer
                              ##
                              ##  @return pointer to esp-netif instance
                              ##

proc esp_netif_create_default_wifi_mesh_netifs*(
    p_netif_sta: ptr ptr esp_netif_t; p_netif_ap: ptr ptr esp_netif_t): esp_err_t {.
    cdecl, importc: "esp_netif_create_default_wifi_mesh_netifs",
    header: "esp_wifi_default.h".}
  ##
                                  ##  @brief Creates default STA and AP network interfaces for esp-mesh.
                                  ##
                                  ##  Both netifs are almost identical to the default station and softAP, but with
                                  ##  DHCP client and server disabled. Please note that the DHCP client is typically
                                  ##  enabled only if the device is promoted to a root node.
                                  ##
                                  ##  Returns created interfaces which could be ignored setting parameters to NULL
                                  ##  if an application code does not need to save the interface instances
                                  ##  for further processing.
                                  ##
                                  ##  @param[out] p_netif_sta pointer where the resultant STA interface is saved (if non NULL)
                                  ##  @param[out] p_netif_ap pointer where the resultant AP interface is saved (if non NULL)
                                  ##
                                  ##  @return ESP_OK on success
                                  ## 
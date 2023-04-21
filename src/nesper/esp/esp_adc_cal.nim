##
##  SPDX-FileCopyrightText: 2015-2022 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

import ../consts
import driver/adc

const hdr="esp_adc_cal.h"
type
  esp_adc_cal_value_t* {.size: sizeof(cint).} = enum ##
                                                ##  @brief Type of calibration value used in characterization
                                                ##
    ESP_ADC_CAL_VAL_EFUSE_VREF = 0, ## < Characterization based on reference voltage stored in eFuse
    ESP_ADC_CAL_VAL_EFUSE_TP = 1, ## < Characterization based on Two Point values stored in eFuse
    ESP_ADC_CAL_VAL_DEFAULT_VREF = 2, ## < Characterization based on default reference voltage
    ESP_ADC_CAL_VAL_EFUSE_TP_FIT = 3, ## < Characterization based on Two Point values and fitting curve coefficients stored in eFuse
    ESP_ADC_CAL_VAL_MAX

const
  ESP_ADC_CAL_VAL_NOT_SUPPORTED* = ESP_ADC_CAL_VAL_MAX

type
  esp_adc_cal_characteristics_t* {.importc: "esp_adc_cal_characteristics_t",
                                  header: hdr, bycopy.} = object ##
                                                            ##  @brief Structure storing characteristics of an ADC
                                                            ##
                                                            ##  @note Call
                                                            ## esp_adc_cal_characterize() to initialize the structure
                                                            ##
    adc_num* {.importc: "adc_num".}: adc_unit_t ## < ADC number
    atten* {.importc: "atten".}: adc_atten_t ## < ADC attenuation
    bit_width* {.importc: "bit_width".}: adc_bits_width_t ## < ADC bit width
    coeff_a* {.importc: "coeff_a".}: uint32 ## < Gradient of ADC-Voltage curve
    coeff_b* {.importc: "coeff_b".}: uint32 ## < Offset of ADC-Voltage curve
    vref* {.importc: "vref".}: uint32 ## < Vref used by lookup table
    low_curve* {.importc: "low_curve".}: ptr uint32 ## < Pointer to low Vref curve of lookup table (NULL if unused)
    high_curve* {.importc: "high_curve".}: ptr uint32 ## < Pointer to high Vref curve of lookup table (NULL if unused)
    version* {.importc: "version".}: uint8
    ## < ADC Calibration


proc esp_adc_cal_check_efuse*(value_type: esp_adc_cal_value_t): esp_err_t {.cdecl,
    importc: "esp_adc_cal_check_efuse", header: hdr.}
  ##
  ##  @brief Checks if ADC calibration values are burned into eFuse
  ##
  ##  This function checks if ADC reference voltage or Two Point values have been
  ##  burned to the eFuse of the current ESP32
  ##
  ##  @param   value_type  Type of calibration value (ESP_ADC_CAL_VAL_EFUSE_VREF or ESP_ADC_CAL_VAL_EFUSE_TP)
  ##  @note in ESP32S2, only ESP_ADC_CAL_VAL_EFUSE_TP is supported. Some old ESP32S2s do not support this, either.
  ##  In which case you have to calibrate it manually, possibly by performing your own two-point calibration on the chip.
  ##
  ##  @return
  ##       - ESP_OK: The calibration mode is supported in eFuse
  ##       - ESP_ERR_NOT_SUPPORTED: Error, eFuse values are not burned
  ##       - ESP_ERR_INVALID_ARG: Error, invalid argument (ESP_ADC_CAL_VAL_DEFAULT_VREF)
  ##
proc esp_adc_cal_characterize*(adc_num: adc_unit_t; atten: adc_atten_t;
                              bit_width: adc_bits_width_t; default_vref: uint32;
                              chars: ptr esp_adc_cal_characteristics_t): esp_adc_cal_value_t {.
    cdecl, importc: "esp_adc_cal_characterize", header: hdr.}
  ##
  ##  @brief Characterize an ADC at a particular attenuation
  ##
  ##  This function will characterize the ADC at a particular attenuation and generate
  ##  the ADC-Voltage curve in the form of [y = coeff_a * x + coeff_b].
  ##  Characterization can be based on Two Point values, eFuse Vref, or default Vref
  ##  and the calibration values will be prioritized in that order.
  ##
  ##  @note
  ##  For ESP32, Two Point values and eFuse Vref calibration can be enabled/disabled using menuconfig.
  ##  For ESP32s2, only Two Point values calibration and only ADC_WIDTH_BIT_13 is supported. The parameter default_vref is unused.
  ##
  ##
  ##  @param[in]   adc_num         ADC to characterize (ADC_UNIT_1 or ADC_UNIT_2)
  ##  @param[in]   atten           Attenuation to characterize
  ##  @param[in]   bit_width       Bit width configuration of ADC
  ##  @param[in]   default_vref    Default ADC reference voltage in mV (Only in ESP32, used if eFuse values is not available)
  ##  @param[out]  chars           Pointer to empty structure used to store ADC characteristics
  ##
  ##  @return
  ##       - ESP_ADC_CAL_VAL_EFUSE_VREF: eFuse Vref used for characterization
  ##       - ESP_ADC_CAL_VAL_EFUSE_TP: Two Point value used for characterization (only in Linear Mode)
  ##       - ESP_ADC_CAL_VAL_DEFAULT_VREF: Default Vref used for characterization
  ##
proc esp_adc_cal_raw_to_voltage*(adc_reading: uint32; chars: ptr esp_adc_cal_characteristics_t): uint32 {.
    cdecl, importc: "esp_adc_cal_raw_to_voltage", header: hdr.}
  ##
  ##  @brief   Convert an ADC reading to voltage in mV
  ##
  ##  This function converts an ADC reading to a voltage in mV based on the ADC's
  ##  characteristics.
  ##
  ##  @note    Characteristics structure must be initialized before this function
  ##           is called (call esp_adc_cal_characterize())
  ##
  ##  @param[in]   adc_reading     ADC reading
  ##  @param[in]   chars           Pointer to initialized structure containing ADC characteristics
  ##
  ##  @return      Voltage in mV
  ##
proc esp_adc_cal_get_voltage*(channel: adc_channel_t;
                             chars: ptr esp_adc_cal_characteristics_t;
                             voltage: ptr uint32): esp_err_t {.cdecl,
    importc: "esp_adc_cal_get_voltage", header: hdr.}
  ##
  ##  @brief   Reads an ADC and converts the reading to a voltage in mV
  ##
  ##  This function reads an ADC then converts the raw reading to a voltage in mV
  ##  based on the characteristics provided. The ADC that is read is also
  ##  determined by the characteristics.
  ##
  ##  @note    The Characteristics structure must be initialized before this
  ##           function is called (call esp_adc_cal_characterize())
  ##
  ##  @param[in]   channel     ADC Channel to read
  ##  @param[in]   chars       Pointer to initialized ADC characteristics structure
  ##  @param[out]  voltage     Pointer to store converted voltage
  ##
  ##  @return
  ##       - ESP_OK: ADC read and converted to mV
  ##       - ESP_ERR_INVALID_ARG: Error due to invalid arguments
  ##       - ESP_ERR_INVALID_STATE: Reading result is invalid. Try to read again.
  ## 
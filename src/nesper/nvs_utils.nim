
# import tables
# import strutils
import options

import consts
import general
import esp/nvs
import esp/nvs_flash

export nvs_open_mode_t

const TAG = "NVS"

type
  NvsError* = object of OSError
    code*: esp_err_t

  NvsObject* = object
    mode*: nvs_open_mode_t 
    handle*: nvs_handle_t 

proc eraseNvs*(part_name = "nvs"): esp_err_t =
  nvs_flash_erase_partition(part_name)

proc deInitNvs*(part_name = "nvs"): esp_err_t =
  nvs_flash_deinit_partition(part_name)

proc initNvs*(part_name = "nvs") =
  # // Initialize NVS
  var nvs_error = nvs_flash_init_partition(part_name)

  if nvs_error == ESP_ERR_NVS_NO_FREE_PAGES or nvs_error == ESP_ERR_NVS_NEW_VERSION_FOUND:
    logi(TAG, "NVS partition: %s was truncated and needs to be erased", part_name)

    nvs_error = nvs_flash_erase_partition(part_name)
    if ESP_OK != nvs_error:
      raise newEspError[NvsError]("Error (" & $esp_err_to_name(nvs_error) & ") erahsing NVS " & part_name, nvs_error)
    logi(TAG, "NVS partition: %s was erased. Initializing it", part_name)
    nvs_error = nvs_flash_init_partition(part_name)
    if ESP_OK != nvs_error:
      raise newEspError[NvsError]("Error (" & $esp_err_to_name(nvs_error) & ") initializing NVS " & part_name, nvs_error)

  if ESP_OK != nvs_error:
    raise newEspError[NvsError]("Error (" & $esp_err_to_name(nvs_error) & ")", nvs_error)


proc newNvs*(name: string, mode: nvs_open_mode_t; part_name = "nvs"): NvsObject =
  result = NvsObject()
  # // Initialize NVS
  initNvs(part_name)

  #// Open
  logi(TAG, "Opening Non-Volatile Storage (NVS) handle: part: %s section: %s", part_name, name)

  # Set NVS handle
  var nvs_error = nvs_open_from_partition(part_name, name, mode, addr(result.handle))

  if nvs_error != ESP_OK:
    logi(TAG, "Error (%s) opening NVS handle for part/section: %s/%s!", esp_err_to_name(nvs_error), part_name, name)
    raise newEspError[NvsError]("Error opening nvs (" & $esp_err_to_name(nvs_error) & ") " & part_name & "/" & name, nvs_error)

  result.mode = mode

proc getInt*(nvs: NvsObject, key: string): Option[int32] =
  # echo("nvsGetInt: ",  )
  var value: int32 = 0
  ##  value will default to 0, if not set yet in NVS
  ## 
  # echo("nvsGetInt: ", repr(nvs.handle) )
  let nvs_error: esp_err_t = nvs_get_i32(nvs.handle, key.cstring, addr(value))

  case nvs_error
  of ESP_OK:
    some(value)
  of ESP_ERR_NVS_NOT_FOUND:
    # echo("The value is not initialized yet!")
    none[int32]()
  else:
    raise newEspError[NvsError]("Error reading value (" & $esp_err_to_name(nvs_error) & ")", nvs_error)

proc setInt*(nvs: NvsObject, key: string; value: int32) =
  ##  Write
  var nvs_error = nvs_set_i32(nvs.handle, key.cstring, value)
  if (nvs_error != ESP_OK):
    raise newEspError[NvsError]("Error opening nvs (" & $esp_err_to_name(nvs_error) & ")", nvs_error)

  ##  Commit written value.
  echo("Committing updates in NVS ... ")
  nvs_error = nvs_commit(nvs.handle)
  if (nvs_error != ESP_OK):
    raise newEspError[NvsError]("Error opening nvs (" & $esp_err_to_name(nvs_error) & ")", nvs_error)
  
proc setStr*(nvs: NvsObject, key: string, data: string) =
  var nvs_error: esp_err_t
  nvs_error = nvs_set_str(nvs.handle, key.cstring, data.cstring)
  if (nvs_error != ESP_OK):
    raise newEspError[NvsError]("Error writing string (" & $esp_err_to_name(nvs_error) & ")", nvs_error)

proc getStr*(nvs: NvsObject, key: string): Option[string] =
  var required_size: csize_t
  var nvs_error: esp_err_t = nvs_get_str(nvs.handle, "DataCollected", nil, addr(required_size))

  case nvs_error
  of ESP_OK:
    echo("successfully grabbed string size, loading in value..")
    var data: string = newStringOfCap(required_size)
    nvs_error = nvs_get_str(nvs.handle, "DataCollected", data.cstring, addr(required_size))

    if (nvs_error != ESP_OK):
      raise newEspError[NvsError]("Error reading string (" & $esp_err_to_name(nvs_error) & ")", nvs_error)
    else:
      some(data)

  of ESP_ERR_NVS_NOT_FOUND:
    none[string]()
  else:
    raise newEspError[NvsError]("Error reading string size (" & $esp_err_to_name(nvs_error) & ")", nvs_error)

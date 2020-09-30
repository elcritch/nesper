
# import tables
# import strutils
import options

import consts
import general
import nvs_raw
import nvs_flash


type
  NvsError* = object of Exception

var nhandle: nvs_handle_t 
var handle: Option[nvs_handle_t] 
var nvs_error*: esp_err_t

proc doNvsSetup*() =
  # // Initialize NVS
  nvs_error = nvs_flash_init()
  if nvs_error == ESP_ERR_NVS_NO_FREE_PAGES or nvs_error == ESP_ERR_NVS_NEW_VERSION_FOUND:
    echo("NVS partition was truncated and needs to be erased")
    nvs_error = nvs_flash_erase()
    if ESP_OK != nvs_error:
      raise newException(NvsError, "Error (" & $esp_err_to_name(nvs_error) & ") erahsing NVS")
    echo("NVS partition was erased, now initializing it")
    nvs_error = nvs_flash_init()
    if ESP_OK != nvs_error:
      raise newException(NvsError, "Error (" & $esp_err_to_name(nvs_error) & ") initializing NVS")

  #// Open
  echo("Opening Non-Volatile Storage (NVS) handle... ")

  # Set NVS handle
  nvs_error = nvs_open("storage", NVS_READWRITE, addr(nhandle))

  if nvs_error != ESP_OK:
    echo("Error (%s) opening NVS handle!", esp_err_to_name(nvs_error))
    raise newException(NvsError, "Error opening nvs (" & $esp_err_to_name(nvs_error) & ")")

  handle = some(nhandle)

proc doNvsGetInt*(key: string): Option[int32] =
  # echo("nvsGetInt: ",  )
  var value: int32 = 0
  ##  value will default to 0, if not set yet in NVS
  ## 
  # echo("nvsGetInt: ", repr(handle) )
  var nvs_error: esp_err_t = nvs_get_i32(handle.get(), key.cstring, addr(value))

  case nvs_error
  of ESP_OK:
    some(value)
  of ESP_ERR_NVS_NOT_FOUND:
    # echo("The value is not initialized yet!")
    none[int32]()
  else:
    raise newException(NvsError, "Error reading value (" & $esp_err_to_name(nvs_error) & ")")

proc doNvsSetInt*(key: string; value: int32) =
  ##  Write
  var nvs_error = nvs_set_i32(handle.get(), key.cstring, value)
  if (nvs_error != ESP_OK):
    raise newException(NvsError, "Error opening nvs (" & $esp_err_to_name(nvs_error) & ")")

  ##  Commit written value.
  echo("Committing updates in NVS ... ")
  nvs_error = nvs_commit(handle.get())
  if (nvs_error != ESP_OK):
    raise newException(NvsError, "Error opening nvs (" & $esp_err_to_name(nvs_error) & ")")
  
proc doNvsSetStr*(key: string, data: string) =
  var nvs_error: esp_err_t
  nvs_error = nvs_set_str(handle.get(), key.cstring, data.cstring)
  if (nvs_error != ESP_OK):
    raise newException(NvsError, "Error writing string (" & $esp_err_to_name(nvs_error) & ")")


proc doNvsGetStr*(key: string): Option[string] =
  var required_size: csize
  var nvs_error: esp_err_t = nvs_get_str(handle.get(), "DataCollected", nil, addr(required_size))

  case nvs_error
  of ESP_OK:
    echo("successfully grabbed string size, loading in value..")
    var data: string = newStringOfCap(required_size)
    nvs_error = nvs_get_str(handle.get(), "DataCollected", data.cstring, addr(required_size))

    if (nvs_error != ESP_OK):
      raise newException(NvsError, "Error reading string (" & $esp_err_to_name(nvs_error) & ")")
    else:
      some(data)

  of ESP_ERR_NVS_NOT_FOUND:
    none[string]()
  else:
    raise newException(NvsError, "Error reading string size (" & $esp_err_to_name(nvs_error) & ")")

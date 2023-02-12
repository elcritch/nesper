##  Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
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

## *
##  Opaque pointer type representing non-volatile storage handle
##
import ../consts

type
  nvs_handle_t* = uint32

##
##  Pre-IDF V4.0 uses nvs_handle, so leaving the original typedef here for compatibility.
##
##  typedef nvs_handle_t nvs_handle IDF_DEPRECATED("Replace with nvs_handle_t");

const
  ESP_ERR_NVS_BASE* = 0x00001100
  ESP_ERR_NVS_NOT_INITIALIZED* = (ESP_ERR_NVS_BASE + 0x00000001) ## !< The storage driver is not initialized
  ESP_ERR_NVS_NOT_FOUND* = (ESP_ERR_NVS_BASE + 0x00000002) ## !< Id namespace doesn’t exist yet and mode is NVS_READONLY
  ESP_ERR_NVS_TYPE_MISMATCH* = (ESP_ERR_NVS_BASE + 0x00000003) ## !< The type of set or get operation doesn't match the type of value stored in NVS
  ESP_ERR_NVS_READ_ONLY* = (ESP_ERR_NVS_BASE + 0x00000004) ## !< Storage handle was opened as read only
  ESP_ERR_NVS_NOT_ENOUGH_SPACE* = (ESP_ERR_NVS_BASE + 0x00000005) ## !< There is not enough space in the underlying storage to save the value
  ESP_ERR_NVS_INVALID_NAME* = (ESP_ERR_NVS_BASE + 0x00000006) ## !< Namespace name doesn’t satisfy constraints
  ESP_ERR_NVS_INVALID_HANDLE* = (ESP_ERR_NVS_BASE + 0x00000007) ## !< Handle has been closed or is NULL
  ESP_ERR_NVS_REMOVE_FAILED* = (ESP_ERR_NVS_BASE + 0x00000008) ## !< The value wasn’t updated because flash write operation has failed. The value was written however, and update will be finished after re-initialization of nvs, provided that flash operation doesn’t fail again.
  ESP_ERR_NVS_KEY_TOO_LONG* = (ESP_ERR_NVS_BASE + 0x00000009) ## !< Key name is too long
  ESP_ERR_NVS_PAGE_FULL* = (ESP_ERR_NVS_BASE + 0x0000000A) ## !< Internal error; never returned by nvs API functions
  ESP_ERR_NVS_INVALID_STATE* = (ESP_ERR_NVS_BASE + 0x0000000B) ## !< NVS is in an inconsistent state due to a previous error. Call nvs_flash_init and nvs_open again, then retry.
  ESP_ERR_NVS_INVALID_LENGTH* = (ESP_ERR_NVS_BASE + 0x0000000C) ## !< String or blob length is not sufficient to store data
  ESP_ERR_NVS_NO_FREE_PAGES* = (ESP_ERR_NVS_BASE + 0x0000000D) ## !< NVS partition doesn't contain any empty pages. This may happen if NVS partition was truncated. Erase the whole partition and call nvs_flash_init again.
  ESP_ERR_NVS_VALUE_TOO_LONG* = (ESP_ERR_NVS_BASE + 0x0000000E) ## !< String or blob length is longer than supported by the implementation
  ESP_ERR_NVS_PART_NOT_FOUND* = (ESP_ERR_NVS_BASE + 0x0000000F) ## !< Partition with specified name is not found in the partition table
  ESP_ERR_NVS_NEW_VERSION_FOUND* = (ESP_ERR_NVS_BASE + 0x00000010) ## !< NVS partition contains data in new format and cannot be recognized by this version of code
  ESP_ERR_NVS_XTS_ENCR_FAILED* = (ESP_ERR_NVS_BASE + 0x00000011) ## !< XTS encryption failed while writing NVS entry
  ESP_ERR_NVS_XTS_DECR_FAILED* = (ESP_ERR_NVS_BASE + 0x00000012) ## !< XTS decryption failed while reading NVS entry
  ESP_ERR_NVS_XTS_CFG_FAILED* = (ESP_ERR_NVS_BASE + 0x00000013) ## !< XTS configuration setting failed
  ESP_ERR_NVS_XTS_CFG_NOT_FOUND* = (ESP_ERR_NVS_BASE + 0x00000014) ## !< XTS configuration not found
  ESP_ERR_NVS_ENCR_NOT_SUPPORTED* = (ESP_ERR_NVS_BASE + 0x00000015) ## !< NVS encryption is not supported in this version
  ESP_ERR_NVS_KEYS_NOT_INITIALIZED* = (ESP_ERR_NVS_BASE + 0x00000016) ## !< NVS key partition is uninitialized
  ESP_ERR_NVS_CORRUPT_KEY_PART* = (ESP_ERR_NVS_BASE + 0x00000017) ## !< NVS key partition is corrupt
  ESP_ERR_NVS_CONTENT_DIFFERS* = (ESP_ERR_NVS_BASE + 0x00000018) ## !< Internal error; never returned by nvs API functions.  NVS key is different in comparison
  NVS_DEFAULT_PART_NAME* = "nvs"

## *
##  @brief Mode of opening the non-volatile storage
##

type
  nvs_open_mode_t* {.size: sizeof(cint).} = enum
    NVS_READONLY,             ## !< Read only
    NVS_READWRITE             ## !< Read and write


##
##  Pre-IDF V4.0 uses nvs_open_mode, so leaving the original typedef here for compatibility.
##
##  typedef nvs_open_mode_t nvs_open_mode IDF_DEPRECATED("Replace with nvs_open_mode_t");
## *
##  @brief Types of variables
##
##

type
  nvs_type_t* {.size: sizeof(cint).} = enum
    NVS_TYPE_U8 = 0x00000001,   ## !< Type uint8_t
    NVS_TYPE_U16 = 0x00000002,  ## !< Type uint16_t
    NVS_TYPE_U32 = 0x00000004,  ## !< Type uint32_t
    NVS_TYPE_U64 = 0x00000008,  ## !< Type uint64_t
    NVS_TYPE_I8 = 0x00000011,   ## !< Type int8_t
    NVS_TYPE_I16 = 0x00000012,  ## !< Type int16_t
    NVS_TYPE_I32 = 0x00000014,  ## !< Type int32_t
    NVS_TYPE_I64 = 0x00000018,  ## !< Type int64_t
    NVS_TYPE_STR = 0x00000021,  ## !< Type string
    NVS_TYPE_BLOB = 0x00000042, ## !< Type blob
    NVS_TYPE_ANY = 0x000000FF


## *
##  @brief information about entry obtained from nvs_entry_info function
##

type
  nvs_entry_info_t* {.importc: "nvs_entry_info_t", header: "nvs.h", bycopy.} = object
    namespace_name* {.importc: "namespace_name".}: array[16, char] ## !< Namespace to which key-value belong
    key* {.importc: "key".}: array[16, char] ## !< Key of stored key-value pair
    `type`* {.importc: "type".}: nvs_type_t ## !< Type of stored key-value pair


## *
##  Opaque pointer type representing iterator to nvs entries
##

type
  nvs_opaque_iterator_t {.header: "<nvs.h>", importc: "nvs_iterator_t".} = object
  nvs_iterator_t* = ptr nvs_opaque_iterator_t

## *
##  @brief      Open non-volatile storage with a given namespace from the default NVS partition
##
##  Multiple internal ESP-IDF and third party application modules can store
##  their key-value pairs in the NVS module. In order to reduce possible
##  conflicts on key names, each module can use its own namespace.
##  The default NVS partition is the one that is labelled "nvs" in the partition
##  table.
##
##  @param[in]  name        Namespace name. Maximal length is determined by the
##                          underlying implementation, but is guaranteed to be
##                          at least 15 characters. Shouldn't be empty.
##  @param[in]  open_mode   NVS_READWRITE or NVS_READONLY. If NVS_READONLY, will
##                          open a handle for reading only. All write requests will
##              be rejected for this handle.
##  @param[out] out_handle  If successful (return code is zero), handle will be
##                          returned in this argument.
##
##  @return
##              - ESP_OK if storage handle was opened successfully
##              - ESP_ERR_NVS_NOT_INITIALIZED if the storage driver is not initialized
##              - ESP_ERR_NVS_PART_NOT_FOUND if the partition with label "nvs" is not found
##              - ESP_ERR_NVS_NOT_FOUND id namespace doesn't exist yet and
##                mode is NVS_READONLY
##              - ESP_ERR_NVS_INVALID_NAME if namespace name doesn't satisfy constraints
##              - other error codes from the underlying storage driver
##

proc nvs_open*(name: cstring; open_mode: nvs_open_mode_t;
              out_handle: ptr nvs_handle_t): esp_err_t {.cdecl, importc: "nvs_open",
    header: "nvs.h".}


## *
##  @brief      Open non-volatile storage with a given namespace from specified partition
##
##  The behaviour is same as nvs_open() API. However this API can operate on a specified NVS
##  partition instead of default NVS partition. Note that the specified partition must be registered
##  with NVS using nvs_flash_init_partition() API.
##
##  @param[in]  part_name   Label (name) of the partition of interest for object read/write/erase
##  @param[in]  name        Namespace name. Maximal length is determined by the
##                          underlying implementation, but is guaranteed to be
##                          at least 15 characters. Shouldn't be empty.
##  @param[in]  open_mode   NVS_READWRITE or NVS_READONLY. If NVS_READONLY, will
##                          open a handle for reading only. All write requests will
##              be rejected for this handle.
##  @param[out] out_handle  If successful (return code is zero), handle will be
##                          returned in this argument.
##
##  @return
##              - ESP_OK if storage handle was opened successfully
##              - ESP_ERR_NVS_NOT_INITIALIZED if the storage driver is not initialized
##              - ESP_ERR_NVS_PART_NOT_FOUND if the partition with specified name is not found
##              - ESP_ERR_NVS_NOT_FOUND id namespace doesn't exist yet and
##                mode is NVS_READONLY
##              - ESP_ERR_NVS_INVALID_NAME if namespace name doesn't satisfy constraints
##              - other error codes from the underlying storage driver
##
proc nvs_open_from_partition*(part_name: cstring; name: cstring;
                             open_mode: nvs_open_mode_t;
                             out_handle: ptr nvs_handle_t): esp_err_t {.cdecl,
    importc: "nvs_open_from_partition", header: "nvs.h".}


## *@{
## *
##  @brief      set value for given key
##
##  This family of functions set value for the key, given its name. Note that
##  actual storage will not be updated until nvs_commit function is called.
##
##  @param[in]  handle  Handle obtained from nvs_open function.
##                      Handles that were opened read only cannot be used.
##  @param[in]  key     Key name. Maximal length is determined by the underlying
##                      implementation, but is guaranteed to be at least
##                      15 characters. Shouldn't be empty.
##  @param[in]  value   The value to set.
##                      For strings, the maximum length (including null character) is
##                      4000 bytes.
##
##  @return
##              - ESP_OK if value was set successfully
##              - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL
##              - ESP_ERR_NVS_READ_ONLY if storage handle was opened as read only
##              - ESP_ERR_NVS_INVALID_NAME if key name doesn't satisfy constraints
##              - ESP_ERR_NVS_NOT_ENOUGH_SPACE if there is not enough space in the
##                underlying storage to save the value
##              - ESP_ERR_NVS_REMOVE_FAILED if the value wasn't updated because flash
##                write operation has failed. The value was written however, and
##                update will be finished after re-initialization of nvs, provided that
##                flash operation doesn't fail again.
##              - ESP_ERR_NVS_VALUE_TOO_LONG if the string value is too long
##

proc nvs_set_i8*(handle: nvs_handle_t; key: cstring; value: int8): esp_err_t {.cdecl,
    importc: "nvs_set_i8", header: "nvs.h".}
proc nvs_set_u8*(handle: nvs_handle_t; key: cstring; value: uint8): esp_err_t {.cdecl,
    importc: "nvs_set_u8", header: "nvs.h".}
proc nvs_set_i16*(handle: nvs_handle_t; key: cstring; value: int16): esp_err_t {.
    cdecl, importc: "nvs_set_i16", header: "nvs.h".}
proc nvs_set_u16*(handle: nvs_handle_t; key: cstring; value: uint16): esp_err_t {.
    cdecl, importc: "nvs_set_u16", header: "nvs.h".}
proc nvs_set_i32*(handle: nvs_handle_t; key: cstring; value: int32): esp_err_t {.
    cdecl, importc: "nvs_set_i32", header: "nvs.h".}
proc nvs_set_u32*(handle: nvs_handle_t; key: cstring; value: uint32): esp_err_t {.
    cdecl, importc: "nvs_set_u32", header: "nvs.h".}
proc nvs_set_i64*(handle: nvs_handle_t; key: cstring; value: int64): esp_err_t {.
    cdecl, importc: "nvs_set_i64", header: "nvs.h".}
proc nvs_set_u64*(handle: nvs_handle_t; key: cstring; value: uint64): esp_err_t {.
    cdecl, importc: "nvs_set_u64", header: "nvs.h".}
proc nvs_set_str*(handle: nvs_handle_t; key: cstring; value: cstring): esp_err_t {.
    cdecl, importc: "nvs_set_str", header: "nvs.h".}


## *@}
## *
##  @brief       set variable length binary value for given key
##
##  This family of functions set value for the key, given its name. Note that
##  actual storage will not be updated until nvs_commit function is called.
##
##  @param[in]  handle  Handle obtained from nvs_open function.
##                      Handles that were opened read only cannot be used.
##  @param[in]  key     Key name. Maximal length is 15 characters. Shouldn't be empty.
##  @param[in]  value   The value to set.
##  @param[in]  length  length of binary value to set, in bytes; Maximum length is
##                      508000 bytes or (97.6% of the partition size - 4000) bytes
##                      whichever is lower.
##
##  @return
##              - ESP_OK if value was set successfully
##              - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL
##              - ESP_ERR_NVS_READ_ONLY if storage handle was opened as read only
##              - ESP_ERR_NVS_INVALID_NAME if key name doesn't satisfy constraints
##              - ESP_ERR_NVS_NOT_ENOUGH_SPACE if there is not enough space in the
##                underlying storage to save the value
##              - ESP_ERR_NVS_REMOVE_FAILED if the value wasn't updated because flash
##                write operation has failed. The value was written however, and
##                update will be finished after re-initialization of nvs, provided that
##                flash operation doesn't fail again.
##              - ESP_ERR_NVS_VALUE_TOO_LONG if the value is too long
##

proc nvs_set_blob*(handle: nvs_handle_t; key: cstring; value: pointer; length: csize_t): esp_err_t {.
    cdecl, importc: "nvs_set_blob", header: "nvs.h".}


## *@{
## *
##  @brief      get value for given key
##
##  These functions retrieve value for the key, given its name. If key does not
##  exist, or the requested variable type doesn't match the type which was used
##  when setting a value, an error is returned.
##
##  In case of any error, out_value is not modified.
##
##  All functions expect out_value to be a pointer to an already allocated variable
##  of the given type.
##
##  \code{c}
##  // Example of using nvs_get_i32:
##  int32_t max_buffer_size = 4096; // default value
##  esp_err_t err = nvs_get_i32(my_handle, "max_buffer_size", &max_buffer_size);
##  assert(err == ESP_OK || err == ESP_ERR_NVS_NOT_FOUND);
##  // if ESP_ERR_NVS_NOT_FOUND was returned, max_buffer_size will still
##  // have its default value.
##
##  \endcode
##
##  @param[in]     handle     Handle obtained from nvs_open function.
##  @param[in]     key        Key name. Maximal length is determined by the underlying
##                            implementation, but is guaranteed to be at least
##                            15 characters. Shouldn't be empty.
##  @param         out_value  Pointer to the output value.
##                            May be NULL for nvs_get_str and nvs_get_blob, in this
##                            case required length will be returned in length argument.
##
##  @return
##              - ESP_OK if the value was retrieved successfully
##              - ESP_ERR_NVS_NOT_FOUND if the requested key doesn't exist
##              - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL
##              - ESP_ERR_NVS_INVALID_NAME if key name doesn't satisfy constraints
##              - ESP_ERR_NVS_INVALID_LENGTH if length is not sufficient to store data
##

proc nvs_get_i8*(handle: nvs_handle_t; key: cstring; out_value: ptr int8): esp_err_t {.
    cdecl, importc: "nvs_get_i8", header: "nvs.h".}
proc nvs_get_u8*(handle: nvs_handle_t; key: cstring; out_value: ptr uint8): esp_err_t {.
    cdecl, importc: "nvs_get_u8", header: "nvs.h".}
proc nvs_get_i16*(handle: nvs_handle_t; key: cstring; out_value: ptr int16): esp_err_t {.
    cdecl, importc: "nvs_get_i16", header: "nvs.h".}
proc nvs_get_u16*(handle: nvs_handle_t; key: cstring; out_value: ptr uint16): esp_err_t {.
    cdecl, importc: "nvs_get_u16", header: "nvs.h".}
proc nvs_get_i32*(handle: nvs_handle_t; key: cstring; out_value: ptr int32): esp_err_t {.
    cdecl, importc: "nvs_get_i32", header: "nvs.h".}
proc nvs_get_u32*(handle: nvs_handle_t; key: cstring; out_value: ptr uint32): esp_err_t {.
    cdecl, importc: "nvs_get_u32", header: "nvs.h".}
proc nvs_get_i64*(handle: nvs_handle_t; key: cstring; out_value: ptr int64): esp_err_t {.
    cdecl, importc: "nvs_get_i64", header: "nvs.h".}
proc nvs_get_u64*(handle: nvs_handle_t; key: cstring; out_value: ptr uint64): esp_err_t {.
    cdecl, importc: "nvs_get_u64", header: "nvs.h".}



## *@}
## *
##  @brief      get value for given key
##
##  These functions retrieve value for the key, given its name. If key does not
##  exist, or the requested variable type doesn't match the type which was used
##  when setting a value, an error is returned.
##
##  In case of any error, out_value is not modified.
##
##  All functions expect out_value to be a pointer to an already allocated variable
##  of the given type.
##
##  nvs_get_str and nvs_get_blob functions support WinAPI-style length queries.
##  To get the size necessary to store the value, call nvs_get_str or nvs_get_blob
##  with zero out_value and non-zero pointer to length. Variable pointed to
##  by length argument will be set to the required length. For nvs_get_str,
##  this length includes the zero terminator. When calling nvs_get_str and
##  nvs_get_blob with non-zero out_value, length has to be non-zero and has to
##  point to the length available in out_value.
##  It is suggested that nvs_get/set_str is used for zero-terminated C strings, and
##  nvs_get/set_blob used for arbitrary data structures.
##
##  \code{c}
##  // Example (without error checking) of using nvs_get_str to get a string into dynamic array:
##  size_t required_size;
##  nvs_get_str(my_handle, "server_name", NULL, &required_size);
##  char* server_name = malloc(required_size);
##  nvs_get_str(my_handle, "server_name", server_name, &required_size);
##
##  // Example (without error checking) of using nvs_get_blob to get a binary data
##  into a static array:
##  uint8_t mac_addr[6];
##  size_t size = sizeof(mac_addr);
##  nvs_get_blob(my_handle, "dst_mac_addr", mac_addr, &size);
##  \endcode
##
##  @param[in]     handle     Handle obtained from nvs_open function.
##  @param[in]     key        Key name. Maximal length is determined by the underlying
##                            implementation, but is guaranteed to be at least
##                            15 characters. Shouldn't be empty.
##  @param         out_value  Pointer to the output value.
##                            May be NULL for nvs_get_str and nvs_get_blob, in this
##                            case required length will be returned in length argument.
##  @param[inout]  length     A non-zero pointer to the variable holding the length of out_value.
##                            In case out_value a zero, will be set to the length
##                            required to hold the value. In case out_value is not
##                            zero, will be set to the actual length of the value
##                            written. For nvs_get_str this includes zero terminator.
##
##  @return
##              - ESP_OK if the value was retrieved successfully
##              - ESP_ERR_NVS_NOT_FOUND if the requested key doesn't exist
##              - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL
##              - ESP_ERR_NVS_INVALID_NAME if key name doesn't satisfy constraints
##              - ESP_ERR_NVS_INVALID_LENGTH if length is not sufficient to store data
##
## *@{

proc nvs_get_str*(handle: nvs_handle_t; key: cstring; out_value: cstring;
                 length: ptr csize_t): esp_err_t {.cdecl, importc: "nvs_get_str",
    header: "nvs.h".}
proc nvs_get_blob*(handle: nvs_handle_t; key: cstring; out_value: pointer;
                  length: ptr csize_t): esp_err_t {.cdecl, importc: "nvs_get_blob",
    header: "nvs.h".}



## *@}
## *
##  @brief      Erase key-value pair with given key name.
##
##  Note that actual storage may not be updated until nvs_commit function is called.
##
##  @param[in]  handle  Storage handle obtained with nvs_open.
##                      Handles that were opened read only cannot be used.
##
##  @param[in]  key     Key name. Maximal length is determined by the underlying
##                      implementation, but is guaranteed to be at least
##                      15 characters. Shouldn't be empty.
##
##  @return
##               - ESP_OK if erase operation was successful
##               - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL
##               - ESP_ERR_NVS_READ_ONLY if handle was opened as read only
##               - ESP_ERR_NVS_NOT_FOUND if the requested key doesn't exist
##               - other error codes from the underlying storage driver
##

proc nvs_erase_key*(handle: nvs_handle_t; key: cstring): esp_err_t {.cdecl,
    importc: "nvs_erase_key", header: "nvs.h".}


## *
##  @brief      Erase all key-value pairs in a namespace
##
##  Note that actual storage may not be updated until nvs_commit function is called.
##
##  @param[in]  handle  Storage handle obtained with nvs_open.
##                      Handles that were opened read only cannot be used.
##
##  @return
##               - ESP_OK if erase operation was successful
##               - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL
##               - ESP_ERR_NVS_READ_ONLY if handle was opened as read only
##               - other error codes from the underlying storage driver
##

proc nvs_erase_all*(handle: nvs_handle_t): esp_err_t {.cdecl,
    importc: "nvs_erase_all", header: "nvs.h".}


## *
##  @brief      Write any pending changes to non-volatile storage
##
##  After setting any values, nvs_commit() must be called to ensure changes are written
##  to non-volatile storage. Individual implementations may write to storage at other times,
##  but this is not guaranteed.
##
##  @param[in]  handle  Storage handle obtained with nvs_open.
##                      Handles that were opened read only cannot be used.
##
##  @return
##              - ESP_OK if the changes have been written successfully
##              - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL
##              - other error codes from the underlying storage driver
##

proc nvs_commit*(handle: nvs_handle_t): esp_err_t {.cdecl, importc: "nvs_commit",
    header: "nvs.h".}


## *
##  @brief      Close the storage handle and free any allocated resources
##
##  This function should be called for each handle opened with nvs_open once
##  the handle is not in use any more. Closing the handle may not automatically
##  write the changes to nonvolatile storage. This has to be done explicitly using
##  nvs_commit function.
##  Once this function is called on a handle, the handle should no longer be used.
##
##  @param[in]  handle  Storage handle to close
##

proc nvs_close*(handle: nvs_handle_t) {.cdecl, importc: "nvs_close", header: "nvs.h".}


## *
##  @note Info about storage space NVS.
##

type
  nvs_stats_t* {.importc: "nvs_stats_t", header: "nvs.h", bycopy.} = object
    used_entries* {.importc: "used_entries".}: csize_t ## *< Amount of used entries.
    free_entries* {.importc: "free_entries".}: csize_t ## *< Amount of free entries.
    total_entries* {.importc: "total_entries".}: csize_t ## *< Amount all available entries.
    namespace_count* {.importc: "namespace_count".}: csize_t ## *< Amount name space.


## *
##  @brief      Fill structure nvs_stats_t. It provides info about used memory the partition.
##
##  This function calculates to runtime the number of used entries, free entries, total entries,
##  and amount namespace in partition.
##
##  \code{c}
##  // Example of nvs_get_stats() to get the number of used entries and free entries:
##  nvs_stats_t nvs_stats;
##  nvs_get_stats(NULL, &nvs_stats);
##  printf("Count: UsedEntries = (%d), FreeEntries = (%d), AllEntries = (%d)\n",
##           nvs_stats.used_entries, nvs_stats.free_entries, nvs_stats.total_entries);
##  \endcode
##
##  @param[in]   part_name   Partition name NVS in the partition table.
##                           If pass a NULL than will use NVS_DEFAULT_PART_NAME ("nvs").
##
##  @param[out]  nvs_stats   Returns filled structure nvs_states_t.
##                           It provides info about used memory the partition.
##
##
##  @return
##              - ESP_OK if the changes have been written successfully.
##                Return param nvs_stats will be filled.
##              - ESP_ERR_NVS_PART_NOT_FOUND if the partition with label "name" is not found.
##                Return param nvs_stats will be filled 0.
##              - ESP_ERR_NVS_NOT_INITIALIZED if the storage driver is not initialized.
##                Return param nvs_stats will be filled 0.
##              - ESP_ERR_INVALID_ARG if nvs_stats equal to NULL.
##              - ESP_ERR_INVALID_STATE if there is page with the status of INVALID.
##                Return param nvs_stats will be filled not with correct values because
##                not all pages will be counted. Counting will be interrupted at the first INVALID page.
##

proc nvs_get_stats*(part_name: cstring; nvs_stats: ptr nvs_stats_t): esp_err_t {.cdecl,
    importc: "nvs_get_stats", header: "nvs.h".}


## *
##  @brief      Calculate all entries in a namespace.
##
##  Note that to find out the total number of records occupied by the namespace,
##  add one to the returned value used_entries (if err is equal to ESP_OK).
##  Because the name space entry takes one entry.
##
##  \code{c}
##  // Example of nvs_get_used_entry_count() to get amount of all key-value pairs in one namespace:
##  nvs_handle_t handle;
##  nvs_open("namespace1", NVS_READWRITE, &handle);
##  ...
##  size_t used_entries;
##  size_t total_entries_namespace;
##  if(nvs_get_used_entry_count(handle, &used_entries) == ESP_OK){
##      // the total number of records occupied by the namespace
##      total_entries_namespace = used_entries + 1;
##  }
##  \endcode
##
##  @param[in]   handle              Handle obtained from nvs_open function.
##
##  @param[out]  used_entries        Returns amount of used entries from a namespace.
##
##
##  @return
##              - ESP_OK if the changes have been written successfully.
##                Return param used_entries will be filled valid value.
##              - ESP_ERR_NVS_NOT_INITIALIZED if the storage driver is not initialized.
##                Return param used_entries will be filled 0.
##              - ESP_ERR_NVS_INVALID_HANDLE if handle has been closed or is NULL.
##                Return param used_entries will be filled 0.
##              - ESP_ERR_INVALID_ARG if nvs_stats equal to NULL.
##              - Other error codes from the underlying storage driver.
##                Return param used_entries will be filled 0.
##

proc nvs_get_used_entry_count*(handle: nvs_handle_t; used_entries: ptr csize_t): esp_err_t {.
    cdecl, importc: "nvs_get_used_entry_count", header: "nvs.h".}


## *
##  @brief       Create an iterator to enumerate NVS entries based on one or more parameters
##
##  \code{c}
##  // Example of listing all the key-value pairs of any type under specified partition and namespace
##  nvs_iterator_t it = nvs_entry_find(partition, namespace, NVS_TYPE_ANY);
##  while (it != NULL) {
##          nvs_entry_info_t info;
##          nvs_entry_info(it, &info);
##          it = nvs_entry_next(it);
##          printf("key '%s', type '%d' \n", info.key, info.type);
##  };
##  // Note: no need to release iterator obtained from nvs_entry_find function when
##  //       nvs_entry_find or nvs_entry_next function return NULL, indicating no other
##  //       element for specified criteria was found.
##  }
##  \endcode
##
##  @param[in]   part_name       Partition name
##
##  @param[in]   namespace_name  Set this value if looking for entries with
##                               a specific namespace. Pass NULL otherwise.
##
##  @param[in]   type            One of nvs_type_t values.
##
##  @return
##           Iterator used to enumerate all the entries found,
##           or NULL if no entry satisfying criteria was found.
##           Iterator obtained through this function has to be released
##           using nvs_release_iterator when not used any more.
##

when ESP_IDF_MAJOR == 4:
    proc nvs_entry_find*(part_name: cstring; namespace_name: cstring; `type`: nvs_type_t): nvs_iterator_t {.
        cdecl, importc: "nvs_entry_find", header: "nvs.h".}
else:
    proc nvs_entry_find*(part_name: cstring; namespace_name: cstring; `type`: nvs_type_t, iter: nvs_iterator_t) {.
        cdecl, importc: "nvs_entry_find", header: "nvs.h".}


## *
##  @brief       Returns next item matching the iterator criteria, NULL if no such item exists.
##
##  Note that any copies of the iterator will be invalid after this call.
##
##  @param[in]   iterator     Iterator obtained from nvs_entry_find function. Must be non-NULL.
##
##  @return
##           NULL if no entry was found, valid nvs_iterator_t otherwise.
##

proc nvs_entry_next*(`iterator`: nvs_iterator_t): nvs_iterator_t {.cdecl,
    importc: "nvs_entry_next", header: "nvs.h".}


## *
##  @brief       Fills nvs_entry_info_t structure with information about entry pointed to by the iterator.
##
##  @param[in]   iterator     Iterator obtained from nvs_entry_find or nvs_entry_next function. Must be non-NULL.
##
##  @param[out]  out_info     Structure to which entry information is copied.
##

proc nvs_entry_info*(`iterator`: nvs_iterator_t; out_info: ptr nvs_entry_info_t) {.
    cdecl, importc: "nvs_entry_info", header: "nvs.h".}


## *
##  @brief       Release iterator
##
##  @param[in]   iterator    Release iterator obtained from nvs_entry_find function. NULL argument is allowed.
##
##

proc nvs_release_iterator*(`iterator`: nvs_iterator_t) {.cdecl,
    importc: "nvs_release_iterator", header: "nvs.h".}

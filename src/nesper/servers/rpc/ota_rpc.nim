import std/sha1, json

import router

import nesper
import nesper/events
import nesper/tasks
import nesper/timers
import nesper/ota_utils

import strutils

const
  FW_CHECK_BITS* = EventBits_t(BIT(9))

var
  connectEventGroup*: EventGroupHandle_t

const TAG = "otaupdate"

var ota: OtaUpdateHandle = nil
var otaId: int = 0
var otaBuff: string

proc checkSha1Hash*(val: string, hash: string) =
    let sh = $secureHash(val)
    if sh != hash:
      raise newException(ValueError, "incorrect hash")

proc addOTAMethods*(rt: var RpcRouter, ota_validation_cb = proc(): bool = true) =

  rpc(rt, "firmware-begin") do(img_head: string, sha1_hash: string) -> JsonNode:
    # Call to begin writing a firmware update to the OTA

    # TODO: add way to reset OTA after it's started? Not sure how...
    if ota != nil:
      raise newException(ValueError, "OTA update already started! Reboot or reset. ")

    # Check the FW Hash
    img_head.checkSha1Hash(sha1_hash)

    # Create new FW Hash
    ota = newOtaUpdateHandle(nil)
    let desc = ota.checkImageHeader(img_head, version_check = true)

    case desc.status:
    of VersionUnchecked, VersionMatchesPreviousInvalid, VersionSameAsCurrent:
      result = % ["incorrect", $desc.status]
    of VersionNewer:
      result = % ["ok", $desc.status]

    ota_id = 1
    ota.begin()

    ota.write(img_head)
    ota_buff = ""

  rpc(rt, "firmware-chunk") do(img_chunk: string, sha1_hash: string, id: int) -> int:
    # Call to write each chunk, the id is just for a double check
    if id != ota_id:
      raise newException(ValueError, "firmware chunk id incorrect!")

    img_chunk.checkSha1Hash(sha1_hash)
    ota_buff.add(img_chunk)

    if ota_buff.len() >= 4096:
      TAG.logd("writing firmware chunk: idx: %d of size: %d", id, ota_buff.len())
      ota.write(ota_buff)
      ota_buff = ""
    else:
      TAG.logd("appending firmware chunk: idx:%d of size:%d", id, ota_buff.len())

    ota_id.inc()
    result = ota.total_written

  rpc(rt, "firmware-finish") do(sha1_hash: string) -> string:
    # Call to finalize firmware after writing all the chunks
    TAG.logd("Writing final block of {ota_buff.len()}")
    ota.write(ota_buff)
    ota_buff = "" # reset buffer string

    TAG.logd("Finalizing: firmware finish fw upload for {sha1_hash}")
    ota.finish()
    delayMillis(12)

    TAG.logd("Done and setting as boot partion")
    ota.set_as_boot_partition()

    TAG.logd("Finalized FW OTA update")
    result = $ota.total_written
    ota = nil
    ota_id = 0

  rpc(rt, "firmware-verify") do() -> string:
    TAG.logd("Remotely Verified FW update")
    firmware_verify(ota_validation_cb)

    return "ok"

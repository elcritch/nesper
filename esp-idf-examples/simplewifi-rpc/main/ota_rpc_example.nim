import nesper
import nesper/ota_utils
import nesper/servers/rpc/rpcsocket_mpack

import json, options
import std/sha1

const TAG = "OTARPC"

# This needs to be global, or it could be a thread local
var ota: OtaUpdateHandle = nil


proc checkSha1Hash*(val: string, hash: string) =
    let sh = $secureHash(val)
    if sh != hash:
      raise newException(ValueError, "incorrect hash")

proc addOTAMethods*(rt: var RpcRouter) =

  # === Rpc Call: check === #
  rpc(rt, "espCheck") do() -> string:
    return "ok"

  # === Rpc Call: Reboot === #
  rpc(rt, "espReboot") do():
    esp_restart()
    raise newException(OSError, "Rebooting  ESP32")


  rpc(rt, "firmware-begin") do(img_head: string, sha1_hash: string) -> JsonNode:
    if ota != nil:
      raise newException(ValueError, "firmware update already started! reboot esp")

    img_head.checkSha1Hash(sha1_hash)

    ota = newOtaUpdateHandle(nil)
    let desc = ota.checkImageHeader(img_head, version_check = true)
    # tuple[status: OtaUpdateStatus, info: esp_app_desc_t]
    case desc.status:
    of VersionUnchecked, VersionMatchesPreviousInvalid, VersionSameAsCurrent:
      result = % ["incorrect", $desc.status]
    of VersionNewer:
      result = % ["ok", $desc.status]

    ota.begin()
    ota.write(img_head)

  rpc(rt, "firmware-chunk") do(img_chunk: string, sha1_hash: string) -> int:
    img_chunk.checkSha1Hash(sha1_hash)
    ota.write(img_chunk)
    TAG.logi("wrote image chunk: size: %d", img_chunk.len())
    result = ota.total_written

  rpc(rt, "firmware-finish") do(sha1_hash: string) -> int:
    # todo: final check of written data with sha1_hash?
    # it seems the ota library does a sha256 check itself
    TAG.logw("finalize: firmware finish %s", sha1_hash)
    ota.finish()
    delayMillis(10)
    TAG.logw("finalize: write finished",)
    ota.set_as_boot_partition()
    TAG.logw("finalize: set as boot",)
    result = ota.total_written
    ota = nil
    return 0

  rpc(rt, "firmware-verify") do() -> string:
    firmware_verify(proc (): bool = true)

    return "ok"

import nesper
import nesper/nvs


let nvs_handle = newNvs("storage", NVS_READONLY)

nvs_handle.setInt("a", 1)

let a = nvs_handle.getInt("a")

echo "a: " & $a

